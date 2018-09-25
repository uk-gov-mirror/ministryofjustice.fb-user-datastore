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

  describe '.kubectl_args' do
    let(:context) {}
    let(:namespace) {}
    let(:bearer_token) {}
    let(:args) {
      {
        context: context,
        namespace: namespace,
        bearer_token: bearer_token
      }
    }
    let(:return_value) { described_class.kubectl_args(args) }

    it 'returns a string' do
      expect(return_value).to be_a(String)
    end

    context 'given no values' do
      it 'returns an empty string' do
        expect(return_value).to be_empty
      end
    end

    context 'given a context' do
      let(:context) { 'my-context' }

      it 'includes --context=(context)' do
        expect(return_value).to include('--context=my-context')
      end

      context 'and a namespace' do
        let(:namespace) { 'my-namespace' }

        it 'includes --namespace=(namespace)' do
          expect(return_value).to include('--namespace=my-namespace')
        end
        it 'includes --context=(context)' do
          expect(return_value).to include('--context=my-context')
        end
      end
    end

    context 'given a namespace' do
      let(:namespace) { 'my-namespace' }

      it 'includes --namespace=(namespace)' do
        expect(return_value).to include('--namespace=my-namespace')
      end
    end

    context 'given a bearer_token' do
      let(:bearer_token) { 'my-bearer_token' }

      it 'includes --token=(bearer_token)' do
        expect(return_value).to include('--token=my-bearer_token')
      end
    end


  end
end
