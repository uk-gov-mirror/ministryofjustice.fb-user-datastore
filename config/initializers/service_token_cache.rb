url = ENV["REDISCLOUD_URL"] || ENV['REDIS_URL']
service_token_cache_class = Adapters::FileCacheAdapter
if url.present?
  begin
    uri = URI.parse(url)
    Rails.configuration.x.service_token_cache_redis = Redis.new(host:uri.host, port:uri.port, password:uri.password)
    service_token_cache_class = Adapters::RedisCacheAdapter
  rescue URI::InvalidURIError
    puts "could not parse a valid Redis URI from #{url} - falling back to file log"
  end
end

Rails.configuration.x.service_token_cache_adapter = service_token_cache_class
