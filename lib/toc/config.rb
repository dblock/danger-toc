module Danger
  module Toc
    module Config
      extend self

      attr_accessor :files
      attr_accessor :header

      # Files to process
      def files=(value)
        @files = value
      end

      # Table of Contents Header
      def header=(value)
        @header = value
      end

      def reset
        self.files = ['README.md']
        self.header = 'Table of Contents'
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
