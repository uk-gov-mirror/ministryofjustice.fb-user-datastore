class EmailsController < ApplicationController
  def create
    supersede_existing_records

    email_data = Email.new(email: email_params[:email_for_sending],
                           service_slug: params[:service_slug],
                           encrypted_payload: email_params[:email_details],
                           expires_at: expires_at,
                           validity: 'valid')

    email_data.save!

    render status: :created, format: :json
  end

  private

  def expires_at
    Time.now + email_params[:duration].minutes
  end

  def email_params
    params.permit(:email_for_sending, :email_details, :duration, :link_template)
  end

  def supersede_existing_records
    email = Email.where(record_retrieval_params).first
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
