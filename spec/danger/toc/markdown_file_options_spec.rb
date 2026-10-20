require File.expand_path('../../spec_helper', __dir__)
require 'tempfile'

describe Danger::Toc::MarkdownFile do
  after { Danger::Toc::Config.reset }

  def parse_markdown(text)
    Tempfile.create(['toc', '.md']) do |file|
      file.write(text)
      file.flush
      yield described_class.new(file.path)
    end
  end

  it 'excludes a leading document title when suggesting a missing TOC' do
    parse_markdown("# Project\n\n## Install\n\n### Details\n\n## Usage\n") do |file|
      expect(file.toc_from_headers).to eq([
                                            '- [Install](#install)',
                                            '  - [Details](#details)',
                                            '- [Usage](#usage)'
                                          ])
    end
  end

  it 'retains peer top-level sections and a lone heading' do
    parse_markdown("# First\n\n# Second\n") do |file|
      expect(file.toc_from_headers).to eq(['- [First](#first)', '- [Second](#second)'])
    end
    parse_markdown("# Only\n") { |file| expect(file.toc_from_headers).to eq(['- [Only](#only)']) }
  end

  it 'uses custom bullets and indentation to generate and validate a TOC' do
    Danger::Toc.config.bullet = '*'
    Danger::Toc.config.indent = 4
    parse_markdown("# Title\n\n## Table of Contents\n\n* [Install](#install)\n    * [Details](#details)\n\n## Install\n\n### Details\n") do |file|
      expect(file).to be_good
      expect(file.toc_from_headers).to eq(['* [Install](#install)', '    * [Details](#details)'])
    end
  end

  it 'limits absolute heading depth before normalizing indentation' do
    Danger::Toc.config.max_depth = 2
    parse_markdown("# Title\n\n## Install\n\n### Details\n\n## Usage\n") do |file|
      expect(file.toc_from_headers).to eq(['- [Install](#install)', '- [Usage](#usage)'])
    end
  end

  it 'supports plus bullets with no indentation' do
    Danger::Toc.config.bullet = '+'
    Danger::Toc.config.indent = 0
    parse_markdown("# Title\n\n## Install\n\n### Details\n") do |file|
      expect(file.toc_from_headers).to eq(['+ [Install](#install)', '+ [Details](#details)'])
    end
  end

  it 'handles a depth limit that excludes all sections' do
    Danger::Toc.config.max_depth = 1
    parse_markdown("# Title\n\n## Install\n") { |file| expect(file.toc_from_headers).to eq([]) }
  end

  it 'supports Kramdown input separately from the anchor format' do
    Danger::Toc.config.parser = 'Kramdown'
    Danger::Toc.config.format = :kramdown
    parse_markdown("# Table of Contents\n\n- [Install](#custom)\n\n## Install {#custom}\n") do |file|
      expect(file).to be_good
      expect(file.headers.first[:id]).to eq('custom')
    end
  end

  it 'propagates unsupported parser errors' do
    Danger::Toc.config.parser = 'MissingParser'
    expect { parse_markdown("# Title\n", &:headers) }.to raise_error(Kramdown::Error, /MissingParser/)
  end

  it 'recognizes a TOC at the end of a file' do
    parse_markdown("# Table of Contents\n\n") do |file|
      expect(file).to have_toc
      expect(file).to be_good
    end
  end

  it 'shows insertions, deletions and limited surrounding context in a diff' do
    parse_markdown("# Table of Contents\n\n- [Wrong](#wrong)\n- [Removed](#removed)\n\n## Right\n") do |file|
      expect(file.toc_diff).to include('-- [Wrong](#wrong)', '-- [Removed](#removed)', '+- [Right](#right)')
    end
    parse_markdown("# Table of Contents\n\n- [One](#one)\n\n## One\n\n## Two\n") do |file|
      expect(file.toc_diff).to eq(" - [One](#one)\n+- [Two](#two)")
    end
  end

  it 'omits distant unchanged entries from a diff' do
    entries = (1..12).map { |number| "- [Section #{number}](#section-#{number})" }
    headings = (1..12).map { |number| "## Section #{number}" }
    entries[7] = '- [Wrong](#wrong)'
    parse_markdown("# Table of Contents\n\n#{entries.join("\n")}\n\n#{headings.join("\n\n")}\n") do |file|
      expect(file.toc_diff.lines.length).to eq(6)
      expect(file.toc_diff).to start_with(' - [Section 6](#section-6)')
      expect(file.toc_diff).to end_with(' - [Section 10](#section-10)')
      expect(file.toc_diff).to include('-- [Wrong](#wrong)', '+- [Section 8](#section-8)')
    end
  end
end
