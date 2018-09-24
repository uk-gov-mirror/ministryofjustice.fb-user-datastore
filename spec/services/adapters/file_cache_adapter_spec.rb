require 'rails_helper'

describe Adapters::FileCacheAdapter do
  let(:cache_dir) { 'example cache dir' }

  describe '.get' do
    before do
      allow(File).to receive(:read).with('file path for key').and_return('file contents')
      allow(described_class).to receive(:file_path).with('key').and_return('file path for key')
    end

    it 'creates the cache_dir if needed' do
      expect(described_class).to receive(:create_cache_dir_if_needed!)
      described_class.get('key')
    end

    it 'gets the file path for the given key' do
      expect(described_class).to receive(:file_path).with('key').and_return('file path for key')
      described_class.get('key')
    end

    it 'returns the file contents' do
      expect(described_class.get('key')).to eq('file contents')
    end
  end

  describe '.put' do
    let(:mock_file) { double(File, :<< => true) }
    let(:value) { 'some value' }
    before do
      allow(File).to receive(:open).with('file path for key', 'w').and_yield(mock_file)
      allow(described_class).to receive(:file_path).with('key').and_return('file path for key')
    end

    it 'creates the cache_dir if needed' do
      expect(described_class).to receive(:create_cache_dir_if_needed!)
      described_class.put('key', value)
    end

    it 'gets the file path for the given key' do
      expect(described_class).to receive(:file_path).with('key').and_return('file path for key')
      described_class.put('key', value)
    end

    it 'opens the file_path in overwrite mode' do
      expect(File).to receive(:open).with('file path for key', 'w').and_yield(mock_file)
      described_class.put('key', value)
    end

    it 'overwrites the file_path with the given value plus a terminating new line' do
      expect(mock_file).to receive(:<<).with(value + "\n")
      described_class.put('key', value)
    end
  end

  describe '.create_cache_dir_if_needed!' do
    before do
      allow(described_class).to receive(:cache_dir).and_return(cache_dir)
    end
    context 'when the cache_dir exists' do
      before do
        allow(Dir).to receive(:exists?).with(cache_dir).and_return(true)
      end
      it 'does not create it' do
        expect(FileUtils).to_not receive(:mkdir_p).with(cache_dir)
        described_class.send(:create_cache_dir_if_needed!)
      end
    end
    context 'when the cache_dir does not exist' do
      before do
        allow(Dir).to receive(:exists?).with(cache_dir).and_return(false)
      end
      it 'does create it' do
        expect(FileUtils).to receive(:mkdir_p).with(cache_dir)
        described_class.send(:create_cache_dir_if_needed!)
      end
    end
  end

  describe '.file_path' do
    let(:filename) { 'file name for key' }
    before do
      allow(described_class).to receive(:cache_dir).and_return(cache_dir)
      allow(described_class).to receive(:filename).with('key').and_return(filename)
    end

    it 'returns the cache_dir joined to the filename for the given key' do
      expect(described_class.file_path('key')).to eq('example cache dir/file name for key')
    end
  end

  describe '.filename' do
    it 'returns (given key).tmp' do
      expect(described_class.filename('key')).to eq('key.tmp')
    end
  end

  describe '.cache_dir' do
    it 'returns (rails root)/tmp/cache' do
      expect(described_class.cache_dir).to eq(Rails.root.join('tmp', 'cache'))
    end
  end
end
