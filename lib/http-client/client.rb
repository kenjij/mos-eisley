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
        EM.run do
          MosEisley.logger.debug("POSTing form to #{url}")
          MosEisley::HTTPClient.request(url: url, head: head, body: params, stop: true, &block)
        end
      end
    end

    def self.post_json(url:, params: nil, body: nil, head: {}, &block)
      head['Content-Type'] = 'application/json; charset=utf-8'
      body = S3PO.json_with_object(params) if params
      if EM.reactor_running?
        MosEisley.logger.debug("POSTing JSON to: #{url}")
        MosEisley::HTTPClient.request(url: url, head: head, body: body, &block)
      else
        MosEisley.logger.debug('Starting reactor...')
        EM.run do
          MosEisley.logger.debug("POSTing JSON to #{url}")
          MosEisley::HTTPClient.request(url: url, head: head, body: body, stop: true, &block)
        end
      end
    end

    def self.request(url:, head: nil, body:, stop: false, &block)
      http = EM::HttpRequest.new(url).post(body: body, head: head)
      http.errback do
        MosEisley.logger.error('HTTP error')
        if stop
          EM.stop
          MosEisley.logger.debug('Stopped reactor.')
        end
      end
      http.callback do
        block.call(http) if block_given?
        if stop
          EM.stop
          MosEisley.logger.debug('Stopped reactor.')
        end
      end
    end
  end
end
