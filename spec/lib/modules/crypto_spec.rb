require 'rails_helper'
require 'modules/crypto'

describe Crypto::AES256 do
  let(:key) { '12345678901234567890abcdefabcdef' }
  let(:payload) {
    {
      'some_key' => 'some value'
    }
  }
  let(:plaintext_string) {
    payload.to_json
  }
  let(:encrypted_string) {
    described_class.encrypt(key: key, data: plaintext_string)
  }

  describe 'encrypt' do
    it 'returns a string' do
      expect(encrypted_string).to be_a(String)
    end

    it 'returns a different string to the given string' do
      expect(encrypted_string).to_not eq(plaintext_string)
    end
  end

  describe 'decrypt' do
    let(:decrypted_string) {
      described_class.decrypt(key: key, data: encrypted_string)
    }
    context 'given a previously encrypted string' do
      let(:encrypted_data) { encrypted_string }

      it 'returns the original plain text' do
        expect(decrypted_string).to eq(plaintext_string)
      end
    end
  end
end
