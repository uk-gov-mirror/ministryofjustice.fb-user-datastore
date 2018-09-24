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

    it 'returns the result of the adapter.get call' do
      expect(described_class.get(service_slug)).to eq('get result')
    end
  end

  describe '.put' do
    let(:token) { 'token value' }
    before do
      allow(described_class).to receive(:key_name).with(service_slug).and_return(generated_key_name)
      allow(described_class).to receive(:adapter).and_return(mock_adapter)
    end

    it 'generates a key_name for the given service_slug' do
      expect(described_class).to receive(:key_name).with(service_slug).and_return(generated_key_name)
      described_class.put(service_slug, token)
    end

    it 'puts the given token to the adapter with the generated key name' do
      expect(mock_adapter).to receive(:put).with(generated_key_name, token).and_return(generated_key_name)
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
