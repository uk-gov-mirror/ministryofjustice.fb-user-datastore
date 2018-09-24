class ServiceTokenService
  def self.get(service_slug)
    byebug
    if token = cache.get(service_slug)
      token
    else
      token = ServiceTokenAuthoritativeSource.get(service_slug)
      cache.put(service_slug, token)
      token
    end
  end

  def self.cache
    ServiceTokenCache
  end
end
