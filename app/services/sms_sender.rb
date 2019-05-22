require 'net/http'

class SmsSender
  class OperationFailed < StandardError; end

  attr_reader :sms, :extra_personalisation

  def initialize(sms_data_object:, extra_personalisation: {})
    @sms = sms_data_object
    @extra_personalisation = extra_personalisation
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
    URI.join(uri, 'sms')
  end

  def payload
    hash = {
      service_slug: service_slug,
      sms: sms.to_payload
    }

    if extra_personalisation.present?
      hash[:sms].reverse_merge!(extra_personalisation: extra_personalisation)
    end

    hash
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
