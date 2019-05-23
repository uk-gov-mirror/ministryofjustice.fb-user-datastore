class Email < ApplicationRecord
  validates :service_slug, :encrypted_payload, :expires_at, presence: true

  def expired?
    expires_at < Time.now
  end

  def superseded?
    validity == 'superseded'
  end

  def used?
    validity == 'used'
  end

  def mark_as_used
    update(validity: 'used')
  end
end
