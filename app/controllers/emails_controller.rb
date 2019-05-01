class EmailsController < ApplicationController
  def create
    supersede_existing_records

    email_data = Email.new(email: email_params[:email_for_sending],
                           encrypted_email: email_params[:email],
                           service_slug: params[:service_slug],
                           encrypted_payload: email_params[:email_details],
                           expires_at: expires_at,
                           validity: 'valid')

    if email_data.save
      email_data.send_confirmation_email
      return render status: :created, format: :json
    else
      return unavailable_error
    end
  end

  private

  def expires_at
    Time.now + email_params[:duration].minutes
  end

  def email_params
    params.permit(:email_for_sending, :email, :email_details, :duration, :link_template)
  end

  def supersede_existing_records
    emails = Email.where(record_retrieval_params)
    emails.update_all(validity: 'superseded')
  end

  def record_retrieval_params
    {
      email: email_params[:email_for_sending],
      encrypted_payload: email_params[:email_details],
      service_slug: params[:service_slug]
    }
  end

  def unavailable_error
    render json: { code: 503,
                   name: 'unavailable' }, status: 503
  end
end
