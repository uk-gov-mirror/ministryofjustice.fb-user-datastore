class MobilesController < ApplicationController
  def create
    mobile_data = Mobile.new(service_slug: params[:service_slug],
                             mobile: params[:mobile],
                             encrypted_email: params[:encrypted_email],
                             encrypted_payload: params[:encrypted_details],
                             expires_at: Time.now + (params[:duration].to_i).hours,
                             code: '12345')

    mobile_data.save!
    render json: {}, status: :created
  end
end
