class EmailsController < ApplicationController
  def create
    expires = Time.now + email_params[:duration].minutes

    email_data = Email.new(email: email_params[:email_for_sending],
                           unique_id: SecureRandom.uuid,
                           service_slug: params[:service_slug],
                           encrypted_payload: email_params[:email_details],
                           expires_at: expires)

    email_data.save!

    render status: :created, format: :json
  end

  private

  def email_params
    params.permit(:email_for_sending, :email_details, :duration, :link_template)
  end
end
