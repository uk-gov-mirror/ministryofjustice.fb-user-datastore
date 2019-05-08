class SaveReturnsController < ApplicationController
  def create
    save_return = SaveReturn.find_by(service: params[:service_slug],
                                     encrypted_email: params[:encrypted_email])

    if save_return
      save_return.update(save_return_hash)

      return render json: {}, status: :ok
    else
      if SaveReturn.create(save_return_hash)
        return render json: {}, status: :created
      else
        return head :internal_server_error
      end
    end
  end

  private

  def save_return_hash
    {
      service: params[:service_slug],
      encrypted_email: params[:encrypted_email],
      encrypted_payload: params[:encrypted_details]
    }
  end
end
