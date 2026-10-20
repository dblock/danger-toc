module Danger
  module Toc
    module Config
      extend self

      ATTRIBUTES = %i[
        files
        header
        format
        parser
        bullet
        indent
        max_depth
        report
      ].freeze

      ACCESSORS = ATTRIBUTES.map { |name| :"#{name}=" }

      DELEGATORS = ATTRIBUTES + ACCESSORS

      attr_accessor(*Config::ATTRIBUTES)

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

      def bullet=(value)
        raise ArgumentError, 'bullet must be -, *, or +' unless %w[- * +].include?(value)

        @bullet = value
      end

      def indent=(value)
        raise ArgumentError, 'indent must be a non-negative Integer' unless value.is_a?(Integer) && value >= 0

        @indent = value
      end

      def max_depth=(value)
        raise ArgumentError, 'max_depth must be nil or an Integer between 1 and 6' unless value.nil? || (value.is_a?(Integer) && (1..6).cover?(value))

        @max_depth = value
      end

      def parser=(value)
        raise ArgumentError, 'parser must be a non-empty String' unless value.is_a?(String) && !value.strip.empty?

        @parser = value
      end

      def report=(value)
        raise ArgumentError, 'report must be :full or :diff' unless %i[full diff].include?(value)

        @report = value
      end

      def default_format
        :github
      end

      def reset
        self.files = ['README.md']
        self.header = 'Table of Contents'
        self.format = default_format
        self.parser = 'GFM'
        self.bullet = '-'
        self.indent = 2
        self.max_depth = nil
        self.report = :full
      end

      reset
    end

    class << self
      def configure
        warn '[DEPRECATION] `configure` is deprecated. Please directly configure the Danger plugin via `toc.xyz=` instead.'
        block_given? ? yield(Config) : Config
      end

      def config
        Config
      end
    end
  end
end
