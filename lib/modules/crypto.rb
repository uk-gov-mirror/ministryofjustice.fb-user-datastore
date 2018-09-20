require "openssl"
require "digest"

module Crypto
  module AES256
    # PLEASE NOTE: encrypted text must have the initialization_vector
    # as the first 16 characters
    def self.encrypt(key:, data:)
      cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
      cipher.encrypt
      cipher.key = Digest::SHA256.digest(key)
      cipher.iv = initialization_vector = cipher.random_iv
      cipher_text = cipher.update(data)
      cipher_text << cipher.final
      initialization_vector + cipher_text
    end

    def self.decrypt(key:, data:)
      cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
      cipher.decrypt
      cipher.key = Digest::SHA256.digest(key)
      cipher.iv = data.slice!(0,16)
      d = cipher.update(data)
      d << cipher.final
    end
  end
end
