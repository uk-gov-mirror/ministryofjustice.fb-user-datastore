class SaveReturn < ApplicationRecord
  after_initialize :set_default_values

  private

  def set_default_values
    self.expires_at ||= Time.now + 28.days
  end
end
