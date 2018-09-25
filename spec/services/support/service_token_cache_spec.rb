require 'rails_helper'

describe Support::ServiceTokenCache do
  let(:service_slug) { 'my-service' }
  let(:generated_key_name) { 'key name' }
  let(:mock_adapter) { double('cache adapter', get: 'get result', put: 'put result')}

  describe '.get' do
    before do
      allow(described_class).to receive(:key_name).with(service_slug).and_return(generated_key_name)
      allow(described_class).to receive(:adapter).and_return(mock_adapter)
    end

    it 'generates a key_name for the given service_slug' do
      expect(described_class).to receive(:key_name).with(service_slug).and_return(generated_key_name)
      described_class.get(service_slug)
    end

    it 'gets the generated key name from the adapter' do
      expect(mock_adapter).to receive(:get).with(generated_key_name).and_return(generated_key_name)
      described_class.get(service_slug)
    end

    context 'when no existing cache entry is found' do
      before do
        allow(mock_adapter).to receive(:get).and_return(nil)
      end
      it 'returns nil' do
        expect(described_class.get(service_slug)).to eq(nil)
      end
    end

    context 'when an existing cache entry is found' do
      let(:data) { 'cached data' }
      let(:mock_cache_entry) { instance_double(CacheEntry, expired?: expired, data: data) }
      before do
        allow(CacheEntry).to receive(:deserialize).and_return(mock_cache_entry)
      end
      context 'when the cache entry has expired' do
        let(:expired) { true }
        it 'returns nil' do
          expect(described_class.get(service_slug)).to eq(nil)
        end
      end
      context 'when the cache entry has not expired' do
        let(:expired) { false }

        it 'returns the cached data' do
          expect(described_class.get(service_slug)).to eq('cached data')
        end
      end
    end
  end

  describe '.put' do
    let(:token) { 'token value' }
    before do
      allow(CacheEntry).to receive(:serialize).with(token).and_return('serialized cache entry')
      allow(described_class).to receive(:key_name).with(service_slug).and_return(generated_key_name)
      allow(described_class).to receive(:adapter).and_return(mock_adapter)
    end

    it 'generates a key_name for the given service_slug' do
      expect(described_class).to receive(:key_name).with(service_slug).and_return(generated_key_name)
      described_class.put(service_slug, token)
    end

    it 'serializes a CacheEntry for the given token' do
      expect(CacheEntry).to receive(:serialize).with(token).and_return('serialized cache entry')
      described_class.put(service_slug, token)
    end

    it 'puts the serialized CacheEntry to the adapter with the generated key name' do
      expect(mock_adapter).to receive(:put).with(generated_key_name, 'serialized cache entry')
      described_class.put(service_slug, token)
    end

    it 'returns the result of the adapter.put call' do
      expect(described_class.put(service_slug, token)).to eq('put result')
    end
  end

  describe '.adapter' do
    it 'returns the Rails config x.service_token_cache_adapter' do
      expect(described_class.adapter).to eq(Rails.configuration.x.service_token_cache_adapter)
    end
  end

  describe '.key_name' do
    it 'returns ServiceToken-(given slug)' do
      expect(described_class.key_name('my-slug')).to eq('ServiceToken-my-slug')
    end
  end
end
