class MobilesController < ApplicationController
  def add
    supersede_existing_mobiles

    mobile_data = Mobile.new(service_slug: params[:service_slug],
                             encrypted_email: params[:encrypted_email],
                             encrypted_payload: params[:encrypted_details],
                             expires_at: expires_at)

    if mobile_data.save
      render json: { code: mobile_data.code }, status: :created
    else
      unavailable_error
    end
  end

  def validate
    mobile = Mobile.find_by(service_slug: params[:service_slug],
                            encrypted_email: params[:encrypted_email],
                            code: params[:code])

    return render_code_invalid unless mobile
    return render_code_expired if mobile.expired?
    return render_code_used if mobile.used?
    return render_code_superseded if mobile.superseded?
    return render_code_invalid unless mobile.valid_code?

    mobile.mark_as_used
    render json: { encrypted_details: mobile.encrypted_payload }, status: :ok
  end

  private

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
    30.minutes
  end

  def mobile_record_params
    {
      service_slug: params[:service_slug],
      encrypted_email: params[:encrypted_email]
    }
  end

  def supersede_existing_mobiles
    mobiles = Mobile.where(mobile_record_params)
    mobiles.update_all(validity: 'superseded')
  end

  def unavailable_error
    render json: { code: 503, name: 'unavailable' }, status: 503
  end

  def render_code_invalid
    render json: { code: 401, name: 'code.invalid' }, status: 401
  end

  def render_code_expired
    render json: { code: 401, name: 'code.expired' }, status: 401
  end

  def render_code_used
    render json: { code: 401, name: 'code.used' }, status: 401
  end

  def render_code_superseded
    render json: { code: 401, name: 'code.superseded' }, status: 401
  end
end
