class UserDataController < ApplicationController
  def show
    Rails.logger.debug "in show, params = #{params}"
    Rails.logger.debug "record_retrieval_params = #{record_retrieval_params}"
    @user_data = UserData.find_by!(record_retrieval_params)

    render json: ::UserDataPresenter.new(@user_data), status: :ok
  end

  # To keep things simple and fast on the client, we'll transparently
  # handle create or update in one method, called via POST
  def create_or_update
    @user_data = find_or_build(record_retrieval_params)
    success_status = @user_data.persisted? ? :no_content : :created

    @user_data.payload = user_data_params[:payload]
    @user_data.save!

    render status: success_status, format: :json
  end

  private

  def find_or_build(attributes)
    UserData.where(attributes).first || UserData.new(attributes)
  end

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
