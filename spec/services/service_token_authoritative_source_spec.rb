require 'rails_helper'

describe ServiceTokenAuthoritativeSource do
  describe '.secret_name' do
    before do
      allow(described_class).to receive(:environment_slug).and_return('myenv')
    end

    it 'returns fb-service-(service_slug)-token-(environment_slug)' do
      expect(described_class.secret_name('my-service')).to eq('fb-service-my-service-token-myenv')
    end
  end

  describe '.environment_slug' do
    before do
      allow(ENV).to receive(:[]).with('FB_ENVIRONMENT_SLUG').and_return('my-env')
    end

    it 'returns the environment variable FB_ENVIRONMENT_SLUG' do
      expect(described_class.environment_slug).to eq('my-env')
    end
  end

  describe '.get' do
    before do
      allow(described_class).to receive(:secret_name).with('given slug').and_return('secret name')
      allow(KubectlAdapter).to receive(:get_secret).with('secret name').and_return('kubectl return value')
    end
    it 'gets the secret_name for the given slug' do
      expect(described_class).to receive(:secret_name).with('given slug').and_return('secret name')
      described_class.get('given slug')
    end

    it 'gets the secret from the KubectlAdapter passing the secret_name for the given slug' do
      expect(KubectlAdapter).to receive(:get_secret).with('secret name')
      described_class.get('given slug')
    end

    it 'returns the result of the get_secret call' do
      expect(described_class.get('given slug')).to eq('kubectl return value')
    end
  end

end
