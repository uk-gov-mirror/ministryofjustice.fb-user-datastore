require 'rails_helper'

describe Adapters::RedisCacheAdapter do
  let(:given_key) { 'key' }
  let(:mock_connection) { double('mock connection', get: 'get result', set: 'set result') }

  describe '.connection' do
    it 'returns the x.service_token_cache_redis value from Rails config' do
      expect(described_class.send(:connection)).to eq(Rails.configuration.x.service_token_cache_redis)
    end
  end

  describe '.get' do
    before do
      allow(described_class).to receive(:connection).and_return(mock_connection)
    end

    it 'calls get on the connection with the given key' do
      expect(mock_connection).to receive(:get).with(given_key)
      described_class.get(given_key)
    end

    it 'returns the result of calling connection.get' do
      expect(described_class.get(given_key)).to eq('get result')
    end
  end

  describe '.put' do
    let(:given_value) { 'value' }
    before do
      allow(described_class).to receive(:connection).and_return(mock_connection)
    end

    it 'calls set on the connection with the given key and value' do
      expect(mock_connection).to receive(:set).with(given_key, given_value)
      described_class.put(given_key, given_value)
    end

    it 'returns the result of calling connection.set' do
      expect(described_class.put(given_key, given_value)).to eq('set result')
    end
  end
end
