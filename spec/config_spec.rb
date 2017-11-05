require File.expand_path('../spec_helper', __FILE__)

describe Danger::Toc::Config do
  after(:each) do
    described_class.reset
  end

  describe 'configure' do
    describe 'files' do
      context 'defailt' do
        it 'assumes README.md' do
          expect(Danger::Toc.config.files).to eq ['README.md']
        end
      end
      context 'when valid' do
        before do
          Danger::Toc.configure do |config|
            config.files = ['README.md', 'SOMETHING.md']
          end
        end

        it 'saves configuration' do
          expect(Danger::Toc.config.files).to eq ['README.md', 'SOMETHING.md']
        end
      end
    end
  end
end
