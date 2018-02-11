module MosEisley
  class WebAPI
    BASE_URL = 'https://slack.com/api/'.freeze

    def self.auth_test
      post_to_slack('auth.test', nil, true) do |r|
        MosEisley.config.meta.merge!(r)
        MosEisley.logger.info('Saved meta data.')
      end
    end

    def self.me_message(channel:, text:)
      post_to_slack('chat.meMessage', {channel: channel, text: text})
    end

    def self.post_message(msg)
      post_to_slack('chat.postMessage', msg)
    end

    def self.post_ephemeral(msg)
      post_to_slack('chat.postEphemeral', msg)
    end

    private

    def self.post_to_slack(method, data = nil, abort_on_err = false, &block)
      url = BASE_URL + method
      head = {authorization: "Bearer #{MosEisley.config.bot_access_token}"}
      HTTPClient.post_json(url: url, params: data, head: head) do |h|
        MosEisley.logger.info("POSTed #{method}.")
        r = check_response(h.response)
        abort('Aborting due to Slack error.') if r.nil? && abort_on_err
        yield(r) if block_given?
      end
    end

    def self.check_response(json)
      r = S3PO.parse_json(json)
      if r
        if r[:ok]
          MosEisley.logger.debug("Response from Slack:\n#{r}")
          return r
        else
          MosEisley.logger.error("Slack error:\n#{r}")
        end
      else
        MosEisley.logger.error('Could not parse response; not JSON?')
      end
      return nil
    end
  end
end
