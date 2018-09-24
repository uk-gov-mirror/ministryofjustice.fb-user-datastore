class ServiceTokenService
  def self.get(service_slug)
    if token = cache.get(service_slug)
      token
    else
      token = Support::ServiceTokenAuthoritativeSource.get(service_slug)
      cache.put(service_slug, token)
      token
    end
  end

  def self.cache
    Support::ServiceTokenCache
  end
end
