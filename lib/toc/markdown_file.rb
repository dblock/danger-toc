require 'active_support/core_ext/string/inflections'

module Danger
  module Toc
    class MarkdownFile
      # TODO: make configurable
      TOC = /^(?<depth>\#+)[[:space:]]+(Table of Contents)/

      attr_reader :filename
      attr_reader :exists
      attr_reader :toc
      attr_reader :headers

      def initialize(filename = 'README.md')
        @filename = filename
        @exists = File.exist?(filename)
        if @exists
          parse!
          reduce!
          validate!
        end
      end

      def exists?
        !!@exists
      end

      def bad?
        !good?
      end

      def good?
        !!@good
      end

      def has_toc?
        !!@has_toc
      end

      def toc_from_headers
        headers.map do |header|
          [
            ' ' * header[:depth],
            "- [#{header[:text]}]",
            "(##{header[:text].parameterize})"
          ].compact.join
        end
      end

      private

      # Parse markdown file for TOC.
      def parse!
        @has_toc = false
        @toc = []
        reading_toc = false
        @headers = []
        File.open(filename).each_line do |line|
          line.rstrip!
          next if line.empty?
          unless @has_toc
            if reading_toc = TOC.match(line)
              @headers = [] # drop any headers prior to TOC
              @has_toc = true
              next
            end
          end
          header = /^(?<depth>\#+)[[:space:]]+(?<text>.*)/.match(line)
          reading_toc = false if reading_toc && header
          @toc << line if reading_toc
          @headers << { depth: header['depth'].length, text: header['text'] } if header
        end
      end

      def reduce!
        min_depth = nil
        headers.each do |header|
          min_depth = header[:depth] unless min_depth && min_depth < header[:depth]
        end
        if min_depth
          headers.each do |header|
            header[:depth] -= min_depth
          end
        end
      end

      def validate!
        @good = (toc_from_headers == toc)
      end
    end
  end
end
