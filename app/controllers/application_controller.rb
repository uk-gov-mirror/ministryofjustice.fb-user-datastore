class ApplicationController < ActionController::API
  include Concerns::ErrorHandling
  include Concerns::JWTAuthentication

  before_action :enforce_json_only

  private

  def enforce_json_only
    Rails.logger.debug "request.format = #{request.format}, json? = #{request.format.json?}"
    response.status = :unacceptable unless request.format.json?
  end


end
