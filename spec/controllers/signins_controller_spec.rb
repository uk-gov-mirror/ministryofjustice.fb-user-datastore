require 'rails_helper'

RSpec.describe SigninsController do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:verify_token!)
    request.env['CONTENT_TYPE'] = 'application/json'
    stub_request(:post, "http://localhost:3000/save_return/email_magic_links").to_return(status: 201)
  end

  describe 'GET /service/:service_slug/savereturn/signin/email/:email' do
    let(:do_get!) do
      get :email, params: { service_slug: 'service-slug', email_for_sending: 'user@example.com', email: 'encrypted:user@example.com' }
    end

    describe 'happy path' do
      it 'creates magic link record' do
        expect do
          do_get!
        end.to change(MagicLink, :count).by(1)
      end

      it 'persists magic link record correctly' do
        do_get!

        record = MagicLink.last

        expect(record.service).to eql('service-slug')
        expect(record.email).to eql('user@example.com')
        expect(record.encrypted_email).to eql('encrypted:user@example.com')
        expect(record.expires_at).to be_within(2.hours).of(24.hours.from_now)
        expect(record.validity).to eql('valid')
      end

      it 'pings submitter to send magic link email' do
        mock_sender = double('sender')
        expect(SaveAndReturn::MagicLinkEmailSender).to receive(:new).and_return(mock_sender)
        expect(mock_sender).to receive(:call)

        do_get!
      end
    end

    describe 'if magic link for email already exists' do
      let!(:previous_magic_link) do
        MagicLink.create!(service: 'service-slug',
                          email: 'user@example.com',
                          encrypted_email: 'encrypted:user@example.com',
                          expires_at: 24.hours.from_now)
      end

      it 'marks previous records as superseded' do
        expect do
          do_get!
        end.to change { previous_magic_link.reload.validity }.from('valid').to('superseded')
      end

      it 'creates new magic link record' do
        expect do
          do_get!
        end.to change(MagicLink, :count).by(1)
      end
    end
  end
end
