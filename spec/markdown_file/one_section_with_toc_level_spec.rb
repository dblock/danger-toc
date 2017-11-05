require 'spec_helper'

describe Danger::Toc::MarkdownFile do
  describe 'ONE-SECTION-WITH-TOC-LEVEL.md' do
    let(:filename) { File.expand_path('../../fixtures/markdown_file/ONE-SECTION-WITH-TOC-LEVEL.md', __FILE__) }
    subject do
      Danger::Toc::MarkdownFile.new(filename)
    end
    it 'exists?' do
      expect(subject.exists?).to be true
    end
    it 'has_toc?' do
      expect(subject.has_toc?).to be true
    end
    it 'toc' do
      expect(subject.toc).to eq(['- [What is This?](#what-is-this)'])
    end
    it 'headers' do
      expect(subject.headers).to eq([{ depth: 0, text: 'What is This?' }])
    end
    it 'good?' do
      expect(subject.good?).to be true
    end
    it 'bad?' do
      expect(subject.bad?).to be false
    end
  end
end
