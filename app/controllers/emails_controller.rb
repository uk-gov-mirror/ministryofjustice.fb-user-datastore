class EmailsController < ApplicationController
  def create
    supersede_existing_records

    email_data = Email.new(email: params[:email][:to],
                           encrypted_email: params[:encrypted_email],
                           service_slug: params[:service_slug],
                           encrypted_payload: params[:encrypted_details],
                           validation_url: params[:validation_url],
                           template_context: params[:template_context],
                           expires_at: expires_at,
                           validity: 'valid')

    ActiveRecord::Base.transaction do
      if email_data.save
        EmailSender.new(email_data_object: email_data_object, extra_personalisation: { token: email_data.id }).call
        return render json: {}, status: :created
      else
        return unavailable_error
      end
    end
  end

  def confirm
    email = Email.find_by_id(params[:email_token])

    return render_link_invalid unless email
    return render_expired if email.expired?
    return render_used if email.used?
    return render_superseded if email.superseded?

    email.mark_as_used

    render json: { encrypted_details: email.encrypted_payload }, status: :ok
  end

  private

  def render_link_invalid
    render json: { code: 404,
                   name: 'invalid.link' }, status: 404
  end

  def render_expired
    render json: { code: 410,
                   name: 'expired.link'}, status: 410
  end

  def render_used
    render json: { code: 410,
                   name: 'used.link'}, status: 410
  end

  def render_superseded
    render json: { code: 400,
                   name: 'superseded.link'}, status: 400
  end

  def expires_at
    Time.now + duration
  end

  def duration
    if params[:duration]
      params[:duration].to_i.minutes
    else
      default_duration
    end
  end

  def default_duration
    120.minutes
  end

  def supersede_existing_records
    emails = Email.where(record_retrieval_params)
    emails.update_all(validity: 'superseded')
  end

  def record_retrieval_params
    {
      encrypted_email: params[:encrypted_email],
      service_slug: params[:service_slug]
    }
  end

  def unavailable_error
    render json: { code: 503,
                   name: 'unavailable' }, status: 503
  end

  def email_data_object
    DataObject::Email.new(email_params)
  end

  def email_params
    params.require(:email).permit(:to, :subject, :body, :template_name)
  end
end
