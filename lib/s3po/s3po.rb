require 'json'
require 'time'
require 's3po/generic'
require 's3po/action'
require 's3po/message'

module MosEisley
  module S3PO
    def self.parse_json(json)
      return JSON.parse(json, {symbolize_names: true})
    rescue => e
      MosEisley.logger.warn("JSON parse error: #{e}")
      return nil
    end

    # Convert object into JSON, optionally pretty-format
    # @param obj [Object] any Ruby object
    # @param opts [Hash] any JSON options
    # @return [String] JSON string
    def self.json_with_object(obj, pretty: false, opts: nil)
      return '{}' if obj.nil?
      if pretty
        opts = {
          indent: '  ',
          space: ' ',
          object_nl: "\n",
          array_nl: "\n"
        }
      end
      JSON.fast_generate(MosEisley::S3PO.format_json_value(obj), opts)
    end

    # Return Ruby object/value to JSON standard format
    # @param val [Object]
    # @return [Object]
    def self.format_json_value(val)
      s3po = MosEisley::S3PO
      case val
      when Array
        val.map { |v| s3po.format_json_value(v) }
      when Hash
        val.reduce({}) { |h, (k, v)| h.merge({k => s3po.format_json_value(v)}) }
      when String
        val.encode!('UTF-8', {invalid: :replace, undef: :replace})
      when Time
        val.utc.iso8601
      else
        val
      end
    end

    def self.create_event(e, type = nil)
      type ||= e[:type] if e[:type]
      case type
      when 'message', 'app_mention'
        return Message.new(e)
      when :action
        return Action.new(e)
      else
        return GenericEvent.new(e)
      end
    end
  end
end
