require 's3po/s3po'

module MosEisley
  module Helper
    def logger
      MosEisley.logger
    end

    def parse_command(params)
      cmd = {}
      params.each { |k, v| cmd[k.to_sym] = v }
      return cmd
    end

    # Parse JSON to Hash with key symbolization by default
    def parse_json(json)
      MosEisley::S3PO.parse_json(json)
    end

    def valid_token?(token)
      token == Config.shared.verification_token
    end

    # Convert object into JSON, optionally pretty-format
    # @param obj [Object] any Ruby object
    # @param opts [Hash] any JSON options
    # @return [String] JSON string
    def json_with_object(obj, pretty: true, opts: nil)
      MosEisley::S3PO.json_with_object(obj, pretty: pretty, opts: opts)
    end
  end
end
