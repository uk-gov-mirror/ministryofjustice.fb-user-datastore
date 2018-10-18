class Support::ServiceTokenCache
  def self.get(service_slug)
    begin
      cache_key = key_name(service_slug)
      cached_value = adapter.get(cache_key)
      cache_entry = CacheEntry.deserialize(cached_value)
      cache_entry.expired? ? nil : cache_entry.data
    rescue StandardError => e
      Rails.logger.warn(
        message: I18n.t('error_messages.cache_exception', name: cache_key),
        detail: [e.message, e.backtrace.join("\n")].join("\n")
      )
      nil
    end
  end

  def self.put(service_slug, token)
    adapter.put(key_name(service_slug), CacheEntry.serialize(token))
  end

  private

  def self.adapter
    Rails.configuration.x.service_token_cache_adapter
  end

  def self.key_name(service_slug)
    ["ServiceToken", service_slug].join('-')
  end
end
