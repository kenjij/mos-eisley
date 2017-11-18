module MosEisley

  def self.handlers
    Handler.handlers
  end

  class Handler

    # Load handlers from directories designated in config
    def self.autoload
      MosEisley.config.handler_paths.each { |path|
        load_from_path(path)
      }
    end

    # Load handlers from a directory
    # @param path [String] directory name
    def self.load_from_path(path)
      Dir.chdir(path) {
        Dir.foreach('.') { |f| load f unless File.directory?(f) }
      }
    end

    # Call as often as necessary to add handlers with blocks; each call creates a MosEisley::Handler object
    # @param type [Symbol] :action | :command | :event
    # @param name [String]
    def self.add(type, name = nil, &block)
      @handlers ||= {
        action: [],
        command: [],
        event: []
      }
      @handlers[type] << Handler.new(type, name, &block)
      MosEisley.logger.debug("Added #{type} handler: #{@handlers[type].last}")
    end

    # @return [Hash<Symbol, Array>] containing all the handlers
    def self.handlers
      @handlers
    end

    # Run the handlers, typically called by the server
    # @param event [Hash] from Slack Events API JSON data
    def self.run(type, event)
      logger = MosEisley.logger
      responses = []
      @handlers[type].each do |h|
        responses << h.run(event)
        if h.stopped?
          logger.debug('Handler stop was requested.')
          break
        end
      end
      logger.info("Done running #{type} handlers.")
      responses = [] if type == :event
      merged_res = {}
      # Only take the last response
      r = responses.last
      merged_res = r if r.class == Hash
      # ## Accumulative Response routine ##
      # responses.each do |r|
      #   next unless r.class == Hash
      #   [:response_type, :replace_original].each { |k| merged_res[k] = r[k] if r.has_key?(k) }
      #   if r[:text]
      #     if merged_res[:text]
      #       merged_res[:text] += "\n#{r[:text]}"
      #     else
      #       merged_res[:text] = r[:text]
      #     end
      #   end
      #   if r[:attachments]
      #     merged_res[:attachments] ||= []
      #     merged_res[:attachments] += r[:attachments]
      #   end
      # end
      return nil if merged_res.empty?
      return merged_res
    end

    attr_reader :type, :name

    def initialize(t, n = nil, &block)
      @type = t
      @name = n
      @block = block
      @stopped = false
    end

    def run(event)
      logger = MosEisley.logger
      logger.warn("No block to execute for #{@type} handler: #{self}") unless @block
      logger.debug("Running #{@type} handler: #{self}")
      @stopped = false
      @block.call(event, self)
    rescue => e
      logger.error(e.message)
      logger.error(e.backtrace.join("\n"))
      {text: "Woops, encountered an error."}
    end

    def stop
      @stopped = true
    end

    def stopped?
      @stopped
    end

    def to_s
      "#<#{self.class}:#{self.object_id.to_s(16)}(#{name})>"
    end

  end

end
