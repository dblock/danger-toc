require File.expand_path('spec_helper', __dir__)

describe Danger::Toc::Config do
  it 'rejects invalid options' do
    { files: 'README.md', header: '', format: :unknown, bullet: '.', indent: -1, max_depth: 7, parser: '', report: :unknown }.each do |name, value|
      expect { described_class.new(**{ name => value }) }.to raise_error(ArgumentError)
    end
  end

  it 'snapshots mutable inputs' do
    files = [+'guide.md']
    header = +'Contents'
    config = described_class.new(files: files, header: header)
    files.first.replace('other.md')
    files << 'extra.md'
    header.replace('Changed')
    expect(config.files).to eq(['guide.md'])
    expect(config.header).to eq('Contents')
    expect(config.with).to be_frozen
  end

  it 'supports every option as a global setting and a per-check override' do
    custom = { files: ['guide.md'], header: 'Contents', format: :kramdown, parser: 'Kramdown', bullet: '*', indent: 4, max_depth: 3, report: :diff }
    global = described_class.new
    custom.each { |name, value| global.public_send("#{name}=", value) }
    expect(global.to_h).to eq(custom)
    expect(global.with(**described_class::DEFAULTS).to_h).to eq(described_class::DEFAULTS)
    expect(global.to_h).to eq(custom)
  end

  it 'requires validation for every declared option' do
    described_class::ATTRIBUTES.each do |name|
      expect { described_class.new(**{ name => Object.new }) }.to raise_error(ArgumentError)
    end
  end

  it 'keeps a check snapshot unchanged when defaults are reassigned' do
    global = described_class.new(header: 'Contents', bullet: '*')
    check = global.with(indent: 4)
    global.header = 'New Contents'
    global.bullet = '+'
    expect([check.header, check.bullet, check.indent]).to eq(['Contents', '*', 4])
  end

  it 'rejects unknown overrides and leaves valid defaults intact after invalid assignment' do
    global = described_class.new
    expect { global.with(unknown: true) }.to raise_error(ArgumentError, /Unknown TOC options/)
    expect { global.indent = -1 }.to raise_error(ArgumentError)
    expect(global.indent).to eq(2)
  end
end
