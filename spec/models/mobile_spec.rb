require 'rails_helper'

RSpec.describe Mobile, type: :model do
  it { should validate_presence_of(:service_slug) }
  it { should validate_presence_of(:mobile) }
  it { should validate_presence_of(:encrypted_email) }
  it { should validate_presence_of(:encrypted_payload) }
  it { should validate_presence_of(:expires_at) }
  it { should validate_presence_of(:code) }

  describe '#code' do
    it 'generates 5 digit value' do
      expect(subject.code.to_i).to be_between(10000, 99999)
    end
  end
end
