class UserDataPresenter
  attr_accessor :timestamp, :user_id, :service_slug, :payload

  def initialize(user_data)
    self.timestamp = [
      user_data.created_at, user_data.updated_at
    ].max.try(:iso8601)
    self.user_id = user_data.user_identifier
    self.service_slug = user_data.service_slug
    self.payload = user_data.payload
  end
end
