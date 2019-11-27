class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include Concerns::ErrorHandling

  before_action :authenticate
  before_action :enforce_json_only

  private

  def enforce_json_only
    response.status = :unacceptable unless request.format.json?
  end

  def authenticate
    raise "AUTH_BASIC_PASSWORD must be set" unless ENV["AUTH_BASIC_PASSWORD"].present?
    authenticate_or_request_with_http_basic('API') do |_, password|
      ActiveSupport::SecurityUtils.secure_compare(password, ENV['AUTH_BASIC_PASSWORD'])
    end
  end
end
