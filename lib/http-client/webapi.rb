module MosEisley

  class WebAPI

    BaseURL = 'https://slack.com/api/'

    def self.auth_test
      m = 'auth.test'
      url = BaseURL + m
      head = {authorization: "Bearer #{MosEisley.config.bot_access_token}"}
      HTTPClient.post_form(url: url, head: head) do |h|
        MosEisley.config.meta.merge!(S3PO.parse_json(h.response))
        MosEisley.logger.info('Meta data updated by auth.test call.')
        MosEisley.logger.debug("Meta data:\n#{MosEisley.config.meta}")
      end
    end

    def self.post_message(msg)
      m = 'chat.postMessage'
      url = BaseURL + m
      head = {authorization: "Bearer #{MosEisley.config.bot_access_token}"}
      HTTPClient.post_json(url: url, params: msg, head: head) do |h|
        MosEisley.logger.info('POSTed chat.postMessage')
        MosEisley.logger.debug("chat.postMessage echo:\n#{h.response}")
      end
    end

    def self.post_ephemeral(msg)
      m = 'chat.postEphemeral'
      url = BaseURL + m
      head = {authorization: "Bearer #{MosEisley.config.bot_access_token}"}
      HTTPClient.post_json(url: url, params: msg, head: head) do |h|
        MosEisley.logger.info('POSTed chat.postEphemeral')
        MosEisley.logger.debug("chat.postEphemeral echo:\n#{h.response}")
      end
    end

    # def self.me_message()
    #   m = 'chat.meMessage'
    #   url = BaseURL + m
    # end

  end

end
