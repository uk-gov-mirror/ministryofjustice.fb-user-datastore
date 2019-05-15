require 'rails_helper'

RSpec.describe MagicLink, type: :model do
  describe '#magic_link' do
    subject do
      described_class.create!(email: 'user@example.com',
                              encrypted_email: 'encrypted:user@example.com',
                              validation_url: 'https://example.com',
                              expires_at: 10.days.from_now,
                              service_slug: 'my-service')
    end

    it 'returns correct link' do
      expect(subject.magic_link).to eql("https://example.com/return/magiclink/#{subject.id}")
    end
  end

  describe '#send_magic_link_email' do
    let(:email) { 'user@example.com'  }
    let(:service_slug) { 'my-service'  }

    subject do
      described_class.new(service_slug: service_slug, email: email)
    end

    it 'calls sender' do
      mock = double('sender')

      expect(SaveAndReturn::MagicLinkEmailSender).to receive(:new).with(email: email, magic_link: subject.magic_link).and_return(mock)
      expect(mock).to receive(:call)

      subject.send_magic_link_email
    end
  end
end
