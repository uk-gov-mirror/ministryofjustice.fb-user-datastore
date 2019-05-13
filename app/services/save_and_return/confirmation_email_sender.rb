require 'net/http'

module SaveAndReturn
  class ConfirmationEmailSender
    attr_reader :email, :confirmation_link, :template_context

    def initialize(email:, confirmation_link:, template_context: {})
      @email = email
      @confirmation_link = confirmation_link
      @template_context = template_context
    end

    def call
      response = http.request(request)
    end

    private

    def uri
      URI(ENV['SUBMITTER_URL'])
    end

    def endpoint
      URI.join(uri, 'save_return/email_confirmations')
    end

    def payload
      { service_slug: service_slug,
        email: email,
        confirmation_link: confirmation_link,
        template_context: template_context }
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
