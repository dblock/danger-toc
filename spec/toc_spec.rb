require File.expand_path('spec_helper', __dir__)

describe Danger::Toc do
  after { Danger::Toc.config.reset }

  it 'is a Danger plugin' do
    expect(Danger::DangerToc.new(nil)).to be_a Danger::Plugin
  end

  describe 'with Dangerfile' do
    let(:filename) { File.expand_path('fixtures/markdown_file/one_section_with_toc.md', __dir__) }
    let(:dangerfile) { testing_dangerfile }
    let(:toc) { dangerfile.toc }
    let(:options) { { files: [filename] } }
    let(:status_report) { toc.status_report }

    context 'toc_changes?' do
      it 'finds modified files' do
        allow(toc.git).to receive(:modified_files).and_return([filename])
        allow(toc.git).to receive(:added_files).and_return([])

        expect(toc.toc_changes?(files: [filename])).to be true
      end

      it 'finds added files' do
        allow(toc.git).to receive(:modified_files).and_return([])
        allow(toc.git).to receive(:added_files).and_return([filename])

        expect(toc.toc_changes?(files: [filename])).to be true
      end

      it 'does not found changed files' do
        allow(toc.git).to receive(:modified_files).and_return([])
        allow(toc.git).to receive(:added_files).and_return([])

        expect(toc.toc_changes?(files: [filename])).to be false
      end
    end

    context 'is_toc_correct?' do
      subject do
        toc.check!(**options)
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
        let(:filename) { File.expand_path('fixtures/markdown_file/one_section.md', __dir__) }

        it 'reports errors' do
          expect(subject).to be false
          expect(status_report[:errors]).to eq ["The #{filename} file is missing a TOC."]
          expect(status_report[:warnings]).to eq []
          expect(status_report[:markdowns].map(&:message)).to eq [<<~MARKDOWN
            Here's the expected TOC for #{filename}:

            ```markdown
            # Table of Contents

            - [What is This?](#what-is-this)
            ```
          MARKDOWN
]
        end
      end

      context 'with invalid TOC' do
        let(:filename) { File.expand_path('fixtures/markdown_file/one_section_with_invalid_toc.md', __dir__) }

        it 'reports errors' do
          expect(subject).to be false
          expect(status_report[:errors]).to eq ["The TOC found in #{filename} doesn't match the sections of the file."]
          expect(status_report[:warnings]).to eq []
          expect(status_report[:markdowns].map(&:message)).to eq [<<~MARKDOWN
            Here's the expected TOC for #{filename}:

            ```markdown
            # Table of Contents

            - [What is This?](#what-is-this)
            ```
          MARKDOWN
]
        end

        it 'provides an opt-in diff while still reporting a failure' do
          options[:report] = :diff
          expect(subject).to be false
          expect(status_report[:markdowns].first.message).to include('```diff', '- current, + expected')
          expect(status_report[:errors]).not_to be_empty
        end
      end

      it 'does not leak options between calls or plugin instances' do
        expect(toc.check!(files: [filename], bullet: '*', parser: 'Kramdown')).to be false
        expect(toc.check!(files: [filename])).to be true
        expect(testing_dangerfile.toc.check!(files: [filename])).to be true
      end

      it 'checks every file even when an earlier file fails' do
        expect(toc.check!(files: ['missing-one.md', 'missing-two.md'])).to be false
        expect(status_report[:errors]).to eq(['The missing-one.md file does not exist.', 'The missing-two.md file does not exist.'])
      end

      it 'uses global defaults but leaves them unchanged by per-check overrides' do
        toc.files = [filename]
        toc.bullet = '*'
        expect(toc.check!(bullet: '-')).to be true
        expect(toc.bullet).to eq('*')
        expect(toc.check!).to be false
      end

      it 'exposes every declared option through the plugin' do
        Danger::Toc::Config::ATTRIBUTES.each do |name|
          toc.public_send("#{name}=", Danger::Toc::Config::DEFAULTS.fetch(name))
          expect(toc.public_send(name)).to eq(Danger::Toc::Config::DEFAULTS.fetch(name))
        end
      end

      context 'with a custom toc header' do
        before do
          options[:header] = 'Custom TOC'
        end

        context 'with missing TOC' do
          let(:filename) { File.expand_path('fixtures/markdown_file/one_section.md', __dir__) }

          it 'reports errors' do
            expect(subject).to be false
            expect(status_report[:markdowns].first.message).to include "\n# Custom TOC\n"
          end
        end

        context 'with a custom TOC' do
          let(:filename) { File.expand_path('fixtures/markdown_file/one_section_with_custom_toc.md', __dir__) }

          it 'has no complaints' do
            expect(subject).to be true
            expect(status_report[:errors]).to eq []
            expect(status_report[:warnings]).to eq []
            expect(status_report[:markdowns]).to eq []
          end
        end
      end
    end
  end
end
