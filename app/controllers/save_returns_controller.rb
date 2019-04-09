class SaveReturnsController < ApplicationController
  def create
    if SaveReturn.find_by(save_return_hash)
      return head :ok
    else
      if SaveReturn.create(save_return_hash)
        return head :created
      else
        return head :internal_server_error
      end
    end
  end

  private

  def save_return_params
    params.permit(:email, :user_details)
  end

  def save_return_hash
    {
      service: params[:service_slug],
      encrypted_email: save_return_params[:email],
      encrypted_payload: save_return_params[:user_details]
    }
  end
end
