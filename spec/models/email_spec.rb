require 'rails_helper'

RSpec.describe Email, type: :model do
  it { should validate_presence_of(:service_slug) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:encrypted_payload) }
  it { should validate_presence_of(:expires_at) }

  describe '#confirmation_link' do
    subject do
      described_class.create!(email: 'user@example.com',
                              encrypted_email: 'encrypted:user@example.com',
                              encrypted_payload: 'encrypted:payload',
                              expires_at: 10.days.from_now,
                              service_slug: 'my-service')
    end

    it 'returns correct link' do
      expect(subject.confirmation_link).to eql("https://my-service.form.service.justice.gov.uk/savereturn/email/confirm/#{subject.id}")
    end
  end

  describe '#send_confirmation_email' do
    let(:email) { 'user@example.com'  }
    let(:service_slug) { 'my-service'  }

    subject do
      described_class.new(service_slug: service_slug, email: email)
    end

    it 'calls sender' do
      mock = double('sender')

      expect(SaveReturn::ConfirmationEmailSender).to receive(:new).with(email: email, confirmation_link: subject.confirmation_link).and_return(mock)
      expect(mock).to receive(:call)

      subject.send_confirmation_email
    end
  end
end
