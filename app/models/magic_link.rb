class MagicLink < ApplicationRecord
  def magic_link
    "https://#{service}#{ENV['FORM_URL_SUFFIX']}/return/magiclink/#{id}"
  end

  def send_magic_link_email
    SaveAndReturn::MagicLinkEmailSender.new(email: email, magic_link: magic_link).call
  end
end
