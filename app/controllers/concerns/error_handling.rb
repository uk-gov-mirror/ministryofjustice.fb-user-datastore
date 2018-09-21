module Concerns
  module ErrorHandling
    extend ActiveSupport::Concern

    included do
      rescue_from StandardError do |e|
        render_json_error :server_error,
                          e.class.name.underscore.to_sym,
                          message: e.message,
                          location: e.backtrace[0] unless Rails.env.production?
      end

      rescue_from ActiveRecord::RecordNotFound do |e|
        render_json_error :not_found, :record_not_found
      end
    end

    private

    def render_json_error(status, error_code, extra = {})
      status = Rack::Utils::SYMBOL_TO_STATUS_CODE[status] if status.is_a? Symbol

      error = {
        title: I18n.t("error_messages.#{error_code}.title"),
        status: status
      }.merge(extra)

      detail = I18n.t("error_messages.#{error_code}.detail", default: '')
      error[:detail] = detail unless detail.empty?

      render json: { errors: [error] }, status: status
    end
  end
end
