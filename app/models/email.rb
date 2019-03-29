class Email < ApplicationRecord
  validates :unique_id, :service_slug, :email, :encrypted_payload, :expires_at, presence: true
end
