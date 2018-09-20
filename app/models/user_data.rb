class UserData < ApplicationRecord
  validates :service_slug, presence: true
  validates :user_identifier, presence: true
end
