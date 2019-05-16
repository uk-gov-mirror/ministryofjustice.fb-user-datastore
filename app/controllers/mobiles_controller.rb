class MobilesController < ApplicationController
  def create
    mobile_data = Mobile.new(service_slug: params[:service_slug],
                             mobile: params[:mobile],
                             encrypted_email: params[:encrypted_email],
                             encrypted_payload: params[:encrypted_details],
                             expires_at: Time.now + (params[:duration].to_i).hours,
                             code: mobile_code)

    mobile_data.save!
    render json: {}, status: :created
  end

  private

  def mobile_code
    Array.new(5) { rand(10) }.join
  end
end
