class Support::ServiceTokenCache
  def self.get(service_slug)
    adapter.get(key_name(service_slug))
  end

  def self.put(service_slug, token)
    adapter.put(key_name(service_slug), token)
  end

  private

  def self.adapter
    Rails.configuration.x.service_token_cache_adapter
  end

  def self.key_name(service_slug)
    ["ServiceToken", service_slug].join('-')
  end
end
