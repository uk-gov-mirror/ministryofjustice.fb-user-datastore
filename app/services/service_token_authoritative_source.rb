class ServiceTokenAuthoritativeSource
  def self.get(service_slug)
    KubectlAdapter.get_secret(
      secret_name(service_slug)
    )
  end

  def self.secret_name(service_slug)
    ['fb-service', service_slug, 'token', environment_slug].join('-')
  end

  private

  def self.environment_slug
    ENV['FB_ENVIRONMENT_SLUG']
  end
end
