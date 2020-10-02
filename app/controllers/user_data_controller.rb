require 'mixpanel-ruby'

class UserDataController < ApplicationController
  before_action :verify_jwt_subject!

  def show
    tracker = Mixpanel::Tracker.new('8b7f1520692b15f418aeb3b03dab1c20')
    tracker.track(mix_panel_uuid,
     'datastore received',
     {
       'request_url' => request.url
     }
    )

    @user_data = UserData.find_by!(record_retrieval_params)

    tracker.track(mix_panel_uuid,
      'datastore returned',
     {
       'request_url' => request.url
     }
    )
    render json: ::UserDataPresenter.new(@user_data), status: :ok
  end

  def verify_jwt_subject!
    unless @jwt_payload['sub'] == record_retrieval_params[:user_identifier]
      raise Concerns::JWTAuthentication::SubjectMismatchError
    end
  end

  # To keep things simple and fast on the client, we'll transparently
  # handle create or update in one method, called via POST
  def create_or_update
    @user_data = find_or_build(record_retrieval_params)
    success_status = @user_data.persisted? ? :ok : :created

    @user_data.payload = user_data_params[:payload]
    @user_data.save!

    render json: {}, status: success_status, format: :json
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

  def mix_panel_uuid
    @_mix_panel_uuid ||= (request.headers['mix-panel-uuid'] || 'no-id')
  end
end
