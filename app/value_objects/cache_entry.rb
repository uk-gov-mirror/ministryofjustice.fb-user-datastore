class CacheEntry
  attr_accessor :data, :expire_after

  def initialize(args={})
    @data = args[:data] || args['data']
    @expire_after = args[:expire_after] || args['expire_after'] || default_expire_after
  end

  def default_expire_after(ttl = ENV['SERVICE_TOKEN_CACHE_TTL'])
    CacheEntry.current_time + ttl.to_i.seconds
  end

  def expired?
    @expire_after < CacheEntry.current_time
  end

  # allows easy stubbing in tests
  def self.current_time
    Time.current.utc
  end


  def self.serialize(data)
    # TTL is handled by the CacheEntry itself
    CacheEntry.new(
      data: data
    ).to_json
  end

  def self.deserialize(json)
    CacheEntry.new(
      JSON.parse(
        json
      )
    )
  end
end
