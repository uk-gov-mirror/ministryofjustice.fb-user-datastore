class SigninsController < ApplicationController
  def email
    supersede_existing_records

    magic_link = MagicLink.new(service: params[:service_slug],
                               email: signin_params[:email_for_sending],
                               encrypted_email: signin_params[:email],
                               expires_at: expires_at)

    if magic_link.save
      magic_link.send_magic_link_email
    end
  end

  private

  def signin_params
    params.permit(:email, :email_for_sending)
  end

  def expires_at
    Time.now + 24.hours
  end

  def supersede_existing_records
    magic_links = MagicLink.where(service: params[:service_slug],
                                  encrypted_email: signin_params[:email])

    magic_links.update_all(validity: 'superseded')
  end
end
