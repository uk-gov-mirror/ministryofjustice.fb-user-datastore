class Email < ApplicationRecord
  validates :service_slug, :email, :encrypted_payload, :expires_at, presence: true

  def confirmation_link
    "https://#{service_slug}#{ENV['FORM_URL_SUFFIX']}/savereturn/email/confirm/#{id}"
  end

  def send_confirmation_email
    SaveAndReturn::ConfirmationEmailSender.new(email: email, confirmation_link: confirmation_link).call
  end

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
