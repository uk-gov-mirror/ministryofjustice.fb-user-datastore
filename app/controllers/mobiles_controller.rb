class MobilesController < ApplicationController
  def create
    mobile_data = Mobile.new(service_slug: params[:service_slug],
                             mobile: params[:mobile],
                             encrypted_email: params[:encrypted_email],
                             encrypted_payload: params[:encrypted_details],
                             expires_at: expires_at,
                             code: mobile_code)

    mobile_data.save!
    render json: {}, status: :created
  end

  private

  def mobile_code
    Array.new(5) { rand(10) }.join
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
end
