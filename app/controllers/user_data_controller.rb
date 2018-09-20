class UserDataController < ApplicationController
  def show
    @user_data = UserData.find_by!(user_identifier: params[:user_id],
                                   service_slug: params[:service_slug])

    render json: ::UserDataPresenter.new(@user_data), status: :ok
  end
end
