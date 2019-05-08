class MagicLink < ApplicationRecord
  def magic_link
    "https://#{service_slug}#{ENV['FORM_URL_SUFFIX']}/return/magiclink/#{id}"
  end

  def send_magic_link_email
    SaveAndReturn::MagicLinkEmailSender.new(email: email, magic_link: magic_link).call
  end

  def mark_as_used
    update(validity: 'used')
  end

  def used?
    validity == 'used'
  end

  def expired?
    expires_at < Time.now
  end
end
