require 'rails_helper'

RSpec.describe Email, type: :model do
  it { should validate_presence_of(:service_slug) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:encrypted_payload) }
  it { should validate_presence_of(:expires_at) }
end
