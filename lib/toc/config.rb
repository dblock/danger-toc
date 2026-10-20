module Danger
  module Toc
    class Config
      DEFAULTS = {
        files: ['README.md'].freeze,
        header: 'Table of Contents',
        format: :github,
        parser: 'GFM',
        bullet: '-',
        indent: 2,
        max_depth: nil,
        report: :full
      }.freeze

      ATTRIBUTES = DEFAULTS.keys.freeze
      DELEGATORS = (ATTRIBUTES + ATTRIBUTES.map { |name| :"#{name}=" }).freeze

      VALIDATORS = {
        files: ->(value) { value.is_a?(Array) && value.all? { |file| file.is_a?(String) && !file.strip.empty? } },
        header: ->(value) { value.is_a?(String) && !value.strip.empty? },
        parser: ->(value) { value.is_a?(String) && !value.strip.empty? },
        format: ->(value) { %i[github kramdown].include?(value) },
        bullet: ->(value) { %w[- * +].include?(value) },
        indent: ->(value) { value.is_a?(Integer) && value >= 0 },
        max_depth: ->(value) { value.nil? || (value.is_a?(Integer) && (1..6).cover?(value)) },
        report: ->(value) { %i[full diff].include?(value) }
      }.freeze

      attr_reader(*ATTRIBUTES)

      ATTRIBUTES.each do |name|
        define_method("#{name}=") do |value|
          validate_option!(name, value)
          instance_variable_set("@#{name}", snapshot(value))
        end
      end

      def initialize(**options)
        unknown = options.keys - ATTRIBUTES
        raise ArgumentError, "Unknown TOC options: #{unknown.join(', ')}" unless unknown.empty?

        DEFAULTS.merge(options).each { |name, value| public_send("#{name}=", value) }
      end

      def with(**options)
        self.class.new(**to_h, **options).freeze
      end

      def to_h
        ATTRIBUTES.to_h { |name| [name, public_send(name)] }
      end

      def reset
        DEFAULTS.each { |name, value| public_send("#{name}=", value) }
      end

      private

      def validate_option!(name, value)
        raise ArgumentError, "Invalid TOC #{name}: #{value.inspect}" unless VALIDATORS.fetch(name).call(value)
      end

      def snapshot(value)
        case value
        when Array then value.map { |item| snapshot(item) }.freeze
        when String then value.dup.freeze
        else value
        end
      end
    end

    def self.config
      @config ||= Config.new
    end

    def self.configure
      warn '[DEPRECATION] `configure` is deprecated. Please directly configure the Danger plugin via `toc.xyz=` instead.'
      block_given? ? yield(config) : config
    end
  end
end
