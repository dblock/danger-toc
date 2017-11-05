require File.expand_path('../spec_helper', __FILE__)

describe Danger::Toc do
  after(:each) do
    Danger::Toc::Config.reset
  end

  it 'is a Danger plugin' do
    expect(Danger::DangerToc.new(nil)).to be_a Danger::Plugin
  end

  describe 'with Dangerfile' do
    let(:filename) { File.expand_path('../fixtures/markdown_file/ONE-SECTION-WITH-TOC.md', __FILE__) }
    let(:dangerfile) { testing_dangerfile }
    let(:toc) do
      dangerfile.toc.filenames = [filename]
      dangerfile.toc
    end
    let(:status_report) { toc.status_report }

    context 'is_toc_correct?' do
      subject do
        toc.is_toc_correct?
      end

      context 'without a file' do
        let(:filename) { 'does-not-exist' }
        it 'complains' do
          expect(subject).to be false
          expect(status_report[:errors]).to eq ['The does-not-exist file does not exist.']
        end
      end

      context 'with changes' do
        before do
          allow(toc.git).to receive(:modified_files).and_return([filename])
          allow(toc.git).to receive(:added_files).and_return([])
        end

        it 'has no complaints' do
          expect(subject).to be true
          expect(status_report[:errors]).to eq []
          expect(status_report[:warnings]).to eq []
          expect(status_report[:markdowns]).to eq []
        end
      end

      context 'with missing TOC' do
        let(:filename) { File.expand_path('../fixtures/markdown_file/ONE-SECTION.md', __FILE__) }
        it 'reports errors' do
          expect(subject).to be false
          expect(status_report[:errors]).to eq ["The #{filename} file is missing a TOC. Please add the following."]
          expect(status_report[:warnings]).to eq []
          expect(status_report[:markdowns].map(&:message)).to eq ["```markdown\n# Table of Contents\n\n- [What is This?](#what-is-this)```\n"]
        end
      end

      context 'with invalid TOC' do
        let(:filename) { File.expand_path('../fixtures/markdown_file/ONE-SECTION-WITH-INVALID-TOC.md', __FILE__) }
        it 'reports errors' do
          expect(subject).to be false
          expect(status_report[:errors]).to eq ["The TOC found in #{filename} doesn't match the sections of the file. Please update it to the following."]
          expect(status_report[:warnings]).to eq []
          expect(status_report[:markdowns].map(&:message)).to eq ["```markdown\n# Table of Contents\n\n- [What is This?](#what-is-this)```\n"]
        end
      end
    end
  end
end
