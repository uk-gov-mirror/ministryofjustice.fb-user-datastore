class Mobile < ApplicationRecord
  validates :service_slug, :mobile, :encrypted_email, :encrypted_payload,
            :expires_at, :code, presence: true
end
