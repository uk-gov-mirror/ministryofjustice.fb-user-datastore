class Email < ApplicationRecord
  validates :service_slug, :email, :encrypted_payload, :expires_at, presence: true
end
