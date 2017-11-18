module MosEisley

  def self.config
    Config.shared
  end

  class Config

    # Load Ruby config file
    # @param path [String] config file
    def self.load_config(path)
      MosEisley.logger.debug("Loading config file: #{path}")
      require File.expand_path(path)
      MosEisley.logger.info('Config.load_config done.')
    end

    # Returns the shared instance
    # @return [MosEisley::Config]
    def self.shared
      @shared_config ||= Config.new
    end

    # Call this from your config file
    def self.setup
      yield Config.shared
      MosEisley.logger.debug('Config.setup block executed.')
    end

    attr_accessor :user
    attr_accessor :handler_paths
    attr_accessor :public_folder
    attr_accessor :dump_errors
    attr_accessor :logging

    attr_reader :meta

    attr_accessor :verification_token
    attr_accessor :bot_access_token

    def initialize
      @handler_paths = []
      @dump_errors = false
      @logging = false

      @meta = {}

      @verification_token = nil
      @bot_access_token = ''
    end

    def set_post_boot(&block)
      @post_boot_block = block
    end

    def run_post_boot
      @post_boot_block.call if @post_boot_block
      @post_boot_block = nil
    end

  end

end
