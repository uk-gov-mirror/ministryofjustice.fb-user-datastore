class MobileSigninsController < ApplicationController
  def add
    supersede_existing_records

    code = Code.new(service_slug: params[:service_slug],
                    encrypted_email: params[:encrypted_email],
                    expires_at: expires_at)

    if code.save
      render json: { code: code.code }, status: :created
    end
  end

  def validate
    code = Code.order(created_at: :desc)
               .find_by(service_slug: params[:service_slug],
                        encrypted_email: params[:encrypted_email],
                        code: params[:code])

    return render_code_invalid_error unless code
    return render_code_used_error if code.used?
    return render_code_superseded_error if code.superseded?
    return render_code_expired_error if code.expired?
    return render_code_invalid_error unless code.valid_code?

    code.mark_as_used

    save_return = SaveReturn.find_by(service_slug: code.service_slug,
                                     encrypted_email: code.encrypted_email)

    return render_save_and_return_missing_error unless save_return

    return render json: { encrypted_details: save_return.encrypted_payload }, status: :ok
  end

  private

  def expires_at
    Time.now + duration
  end

  def duration
    params[:duration] ? params[:duration].to_i.minutes : default_duration
  end

  def default_duration
    30.minutes
  end

  def supersede_existing_records
    codes = Code.where(service_slug: params[:service_slug],
                       encrypted_email: params[:encrypted_email])

    codes.update_all(validity: 'superseded')
  end

  def render_code_invalid_error
    render json: { code: 401,
                   name: 'invalid.link' }, status: 401
  end

  def render_code_used_error
    render json: { code: 401,
                   name: 'used.link' }, status: 401
  end

  def render_code_expired_error
    render json: { code: 401,
                   name: 'expired.link' }, status: 401
  end

  def render_code_superseded_error
    render json: { code: 401,
                   name: 'superseded.link' }, status: 401
  end

  def render_save_and_return_missing_error
    render json: { code: 500,
                   name: 'missing.savereturn' }, status: 500
  end
end
