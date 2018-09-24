require 'rails_helper'

describe Adapters::KubectlAdapter do
  let(:secret_name) { 'my-secret' }
  before do
    allow(Adapters::ShellAdapter).to receive(:output_of).and_return('some output')
  end

  describe '.get_secret' do
    let(:kubectl_output) { 'kubectl output]' }
    let(:parsed_json) {
      {
        'data' => {
          'a_key' => 'a value',
          'another_key' => 'another value',
          'token' => 'token value'
        }
      }
    }
    before do
      allow(JSON).to receive(:parse).with(kubectl_output).and_return(parsed_json)
      allow(Base64).to receive(:decode64).with('token value').and_return('decoded token')
      allow(described_class).to receive(:kubectl_cmd).and_return('kubectl cmd')
      allow(Adapters::ShellAdapter).to receive(:output_of).with('kubectl cmd').and_return(kubectl_output)
    end

    it 'calls kubectl_cmd passing the given secret name' do
      expect(described_class).to receive(:kubectl_cmd).with(secret_name)
      described_class.get_secret(secret_name)
    end

    it 'gets the output of the kubectl_cmd' do
      expect(Adapters::ShellAdapter).to receive(:output_of).with('kubectl cmd').and_return(kubectl_output)
      described_class.get_secret(secret_name)
    end

    it 'parses the kubectl output as JSON' do
      expect(JSON).to receive(:parse).with(kubectl_output).and_return(parsed_json)
      described_class.get_secret(secret_name)
    end

    it 'base64-decodes the [data][token] key' do
      expect(Base64).to receive(:decode64).with('token value').and_return('decoded token')
      described_class.get_secret(secret_name)
    end

    it 'returns the decoded token' do
      expect(described_class.get_secret(secret_name)).to eq('decoded token')
      described_class.get_secret(secret_name)
    end
  end
end
