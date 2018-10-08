url = ENV["REDISCLOUD_URL"] || ENV['REDIS_URL']
service_token_cache_class = Adapters::FileCacheAdapter
if url.present?
  begin
    uri_with_protocol = (ENV['REDIS_PROTOCOL'] || 'redis://') + url
    uri = URI.parse(uri_with_protocol)
    Rails.configuration.x.service_token_cache_redis = Redis.new(
      url: uri_with_protocol,
      password: ENV['REDIS_AUTH_TOKEN']
    )
    service_token_cache_class = Adapters::RedisCacheAdapter
  rescue URI::InvalidURIError
    puts "could not parse a valid Redis URI from #{url} - falling back to file log"
  end
end

Rails.configuration.x.service_token_cache_adapter = service_token_cache_class
