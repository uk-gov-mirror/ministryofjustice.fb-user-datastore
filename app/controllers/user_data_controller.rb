class UserDataController < ApplicationController
  def show
    @user_data = UserData.find_by!(record_retrieval_params)

    render json: ::UserDataPresenter.new(@user_data), status: :ok
  end

  # To keep things simple and fast on the client, we'll transparently
  # handle create or update in one method, called via POST
  def create_or_update
    @user_data = UserData.where(record_retrieval_params).first

    if @user_data
      success_status = :no_content
    else
      success_status = :created
      @user_data = UserData.new(record_retrieval_params)
    end

    @user_data.payload = user_data_params[:payload]
    @user_data.save!

    render status: success_status, format: :json
  end

  private

  def record_retrieval_params(opts = params)
    {
      user_identifier: params[:user_id],
      service_slug: params[:service_slug]
    }
  end

  def user_data_params(opts = params)
    opts.permit(:payload)
  end
end
