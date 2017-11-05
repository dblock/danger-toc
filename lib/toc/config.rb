module Danger
  module Toc
    module Config
      extend self

      attr_accessor :files

      def files=(value)
        @files = value
      end

      def reset
        self.files = ['README.md']
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
