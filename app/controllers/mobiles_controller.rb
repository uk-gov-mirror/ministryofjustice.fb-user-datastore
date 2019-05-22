class MobilesController < ApplicationController
  def create
    supersede_existing_mobiles

    mobile_data = Mobile.new(service_slug: params[:service_slug],
                             mobile: params[:sms][:to],
                             encrypted_email: params[:encrypted_email],
                             encrypted_payload: params[:encrypted_details],
                             expires_at: expires_at)

    ActiveRecord::Base.transaction do
      if mobile_data.save
        SmsSender.new(sms_data_object: sms_data_object, extra_personalisation: { code: mobile_data.code }).call
        render json: {}, status: :created
      else
        unavailable_error
      end
    end
  end

  private

  def sms_data_object
    DataObject::Sms.new(sms_params)
  end

  def sms_params
    params.require(:sms).permit(:to, :body, :template_name)
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
    30.minutes
  end

  def mobile_record_params
    {
      service_slug: params[:service_slug],
      mobile: params[:sms][:to]
    }
  end

  def supersede_existing_mobiles
    mobiles = Mobile.where(mobile_record_params)
    mobiles.update_all(validity: 'superseded')
  end

  def unavailable_error
    render json: { code: 503, name: 'unavailable' }, status: 503
  end
end
