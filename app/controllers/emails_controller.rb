class EmailsController < ApplicationController
  def create
    expires = Time.now + email_params[:duration].minutes

    find_record(record_retrieval_params)

    email_data = Email.new(email: email_params[:email_for_sending],
                           service_slug: params[:service_slug],
                           encrypted_payload: email_params[:email_details],
                           expires_at: expires,
                           validity: 'valid')

    email_data.save!

    render status: :created, format: :json
  end

  private

  def email_params
    params.permit(:email_for_sending, :email_details, :duration, :link_template)
  end

  def find_record(attributes)
    email = Email.where(attributes).first
    return if email.nil?

    email.update_attributes!(validity: 'superseded')
  end

  def record_retrieval_params
    {
      email: email_params[:email_for_sending],
      encrypted_payload: email_params[:email_details],
      service_slug: params[:service_slug]
    }
  end
end
