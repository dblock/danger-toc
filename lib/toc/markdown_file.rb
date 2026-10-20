require 'active_support/core_ext/string/inflections'
require 'kramdown-parser-gfm'
require 'diff/lcs'

require_relative 'extractor'
require_relative 'constructors'
require_relative 'config'

module Danger
  module Toc
    class MarkdownFile
      attr_reader :filename, :exists, :toc, :headers, :config

      def initialize(filename = 'README.md', config: Danger::Toc.config.with)
        @config = config
        @filename = filename
        @exists = File.exist?(filename)
        return unless @exists

        parse!
        reduce!
        validate!
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
            ' ' * header[:depth] * config.indent,
            "#{config.bullet} [#{header[:text]}]",
            "(##{header[:id]})"
          ].compact.join
        end
      end

      def toc_diff
        changes = Diff::LCS.sdiff(toc || [], toc_from_headers)
        lines = []
        previous = nil
        diff_context(changes).each do |index|
          lines << '...' if previous && index > previous + 1
          lines.concat(diff_lines(changes[index]))
          previous = index
        end
        lines.join("\n")
      end

      private

      def diff_context(changes)
        changes.each_index.reject { |index| changes[index].action == '=' }.flat_map do |index|
          (([index - 2, 0].max)..([index + 2, changes.length - 1].min)).to_a
        end.uniq.sort
      end

      def diff_lines(change)
        case change.action
        when '!' then ["-#{change.old_element}", "+#{change.new_element}"]
        when '-' then ["-#{change.old_element}"]
        when '+' then ["+#{change.new_element}"]
        else [" #{change.old_element}"]
        end
      end

      # Parse markdown file for TOC.
      def parse!
        md = File.read(filename)
        doc = Kramdown::Document.new(md, input: config.parser)

        extract_toc!(md, doc)
        construct_headers!(doc)
      end

      def extract_toc!(markdown, doc)
        toc_start, toc_end = Danger::Toc::Extractor.convert(doc.root, toc_header: config.header).first
        toc_end ||= markdown.lines.length + 1 if toc_start
        @has_toc = toc_start && toc_end
        @toc = markdown.split("\n")[toc_start, toc_end - toc_start - 1].reject(&:empty?) if @has_toc
      end

      def construct_headers!(doc)
        @headers = Danger::Toc::Constructors.get(config.format).convert(doc.root, toc_header: config.header).first
        headers.shift if !@has_toc && document_title?
        headers.select! { |header| header[:depth] <= config.max_depth } if config.max_depth
      end

      def document_title?
        headers.length > 1 && headers.first[:depth] == 1 && headers.drop(1).all? { |header| header[:depth] > 1 }
      end

      def reduce!
        min_depth = nil
        headers.each do |header|
          min_depth = header[:depth] unless min_depth && min_depth < header[:depth]
        end
        return unless min_depth

        headers.each do |header|
          header[:depth] -= min_depth
        end
      end

      def validate!
        @good = (toc_from_headers == toc)
      end
    end
  end
end
