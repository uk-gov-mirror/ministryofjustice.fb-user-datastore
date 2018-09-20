require 'modules/crypto'

FactoryBot.define do
  factory :user_data do
    service_slug { 'my-service' }
    user_identifier { SecureRandom.uuid }
    payload { Base64.encode64(
      Crypto::AES256.encrypt(
        key: 'abcdef0123456789', data: {'some_key' => 'some value'}.to_json
      )
    ) }
    created_at { Time.current }
    updated_at { nil }
  end
end
