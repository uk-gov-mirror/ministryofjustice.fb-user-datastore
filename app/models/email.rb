class Email < ApplicationRecord
  validates :service_slug, :email, :encrypted_payload, :expires_at, presence: true

  def confirmation_link
    "https://example.com/#{service_slug}/savereturn/email/confirm/#{id}"
  end

  def send_confirmation_email
    SaveReturn::ConfirmationEmailSender.new(email: email, confirmation_link: confirmation_link).call
  end
end
