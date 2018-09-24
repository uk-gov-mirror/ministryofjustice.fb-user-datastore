class RedisCacheAdapter
  def self.get(key)
    connection.get(key)
  end

  def self.put(key, value)
    connection.append(key, value)
  end

  private

  def self.connection
    Rails.configuration.x.service_token_cache_redis
  end
end
