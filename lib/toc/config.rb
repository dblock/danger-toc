module Danger
  module Toc
    module Config
      extend self

      attr_accessor :files, :header
      attr_writer :format

      # Files to process
      def files=(value)
        @files = value
      end

      # Table of Contents Header
      def header=(value)
        @header = value
      end

      def format
        @format ||= default_format
      end

      def default_format
        :github
      end

      def reset
        self.files = ['README.md']
        self.header = 'Table of Contents'
        self.format = default_format
      end

      reset
    end

    class << self
      def configure
        block_given? ? yield(Config) : Config
      end

      def config
        Config
      end
    end
  end
end
