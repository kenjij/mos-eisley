require 'eventmachine'
require 'em-http'


module MosEisley

  class HTTPClient

    def self.post_form(url:, params: nil, head: nil, &block)
      if EM.reactor_running?
        MosEisley.logger.debug("POSTing form to #{url}")
        MosEisley::HTTPClient.request(url: url, head: head, body: params, &block)
      else
        MosEisley.logger.debug('Starting reactor...')
        EM.run {
          MosEisley.logger.debug("POSTing form to #{url}")
          MosEisley::HTTPClient.request(url: url, head: head, body: params, stop: true, &block)
        }
      end
    end

    def self.post_json(url:, params: nil, body: nil, head: {}, &block)
      head.merge!({'Content-Type' => 'application/json'})
      body = S3PO.json_with_object(params) if params
      if EM.reactor_running?
        MosEisley.logger.debug("POSTing JSON to: #{url}")
        MosEisley::HTTPClient.request(url: url, head: head, body: body, &block)
      else
        MosEisley.logger.debug('Starting reactor...')
        EM.run {
          MosEisley.logger.debug("POSTing JSON to #{url}")
          MosEisley::HTTPClient.request(url: url, head: head, body: body, stop: true, &block)
        }
      end
    end

    def self.request(url:, head: nil, body:, stop: false, &block)
      http = EM::HttpRequest.new(url).post(body: body, head: head)
      http.errback {
        MosEisley.logger.error('HTTP error')
        if stop
          EM.stop
          MosEisley.logger.debug('Stopped reactor.')
        end
      }
      http.callback {
        block.call(http) if block_given?
        if stop
          EM.stop
          MosEisley.logger.debug('Stopped reactor.')
        end
      }
    end

  end

end
