require 'net/http'

module SaveAndReturn
  class ProgressSavedEmailSender
    class OperationFailed < StandardError; end

    attr_reader :email

    def initialize(email_data_object:)
      @email = email_data_object
    end

    def call
      response = http.request(request)

      raise OperationFailed.new unless response.code.to_i == 201
    end

    private

    def uri
      URI(ENV['SUBMITTER_URL'])
    end

    def endpoint
      URI.join(uri, 'save_return/email_progress_saved')
    end

    def payload
      {
        service_slug: service_slug,
        email: email.to_payload
      }
    end

    def service_slug
      'datastore'
    end

    def jwt_payload
      { iat: Time.now.to_i }
    end

    def http
      Net::HTTP.new(endpoint.host, endpoint.port)
    end

    def request
      request = Net::HTTP::Post.new(endpoint.path, 'Content-Type' => 'application/json', 'X-Access-Token' => JWT.encode(jwt_payload, ENV['SERVICE_TOKEN'], 'HS256'))
      request.body = payload.to_json
      request
    end
  end
end
