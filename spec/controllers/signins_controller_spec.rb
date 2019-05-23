require 'rails_helper'

RSpec.describe SigninsController do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:verify_token!)
    request.env['CONTENT_TYPE'] = 'application/json'
  end

  describe 'GET /service/:service_slug/savereturn/signin/email/:email' do
    let(:json_hash) do
      {
        encrypted_email: 'encrypted:user@example.com',
      }
    end

    let(:do_post!) do
      post :email, params: { service_slug: 'service-slug' },
                   body: json_hash.to_json
    end

    describe 'happy path' do
      it 'creates magic link record' do
        expect do
          do_post!
        end.to change(MagicLink, :count).by(1)
      end

      it 'persists magic link record correctly' do
        do_post!

        record = MagicLink.last

        expect(record.service_slug).to eql('service-slug')
        expect(record.encrypted_email).to eql('encrypted:user@example.com')
        expect(record.expires_at).to be_within(2.hours).of(24.hours.from_now)
        expect(record.validity).to eql('valid')
      end

      it 'responds with magiclink' do
        do_post!
        record = MagicLink.last

        expect(JSON.parse(response.body)).to eql({"token" => record.id})
      end
    end

    describe 'if magic link for email already exists' do
      let!(:previous_magic_link) do
        MagicLink.create!(service_slug: 'service-slug',
                          encrypted_email: 'encrypted:user@example.com',
                          expires_at: 24.hours.from_now)
      end

      it 'marks previous records as superseded' do
        expect do
          do_post!
        end.to change { previous_magic_link.reload.validity }.from('valid').to('superseded')
      end

      it 'creates new magic link record' do
        expect do
          do_post!
        end.to change(MagicLink, :count).by(1)
      end
    end
  end

  describe 'POST /service/:service_slug/savereturn/signin/magiclink' do
    let(:json_hash) do
      { 'magiclink': magic_link.id }
    end

    let(:magic_link) do
      MagicLink.create!(service_slug: 'service-slug',
                        encrypted_email: 'encrypted:user@example.com',
                        expires_at: 24.hours.from_now)
    end

    let(:save_return) do
      SaveReturn.create!(service_slug: 'service-slug',
                         encrypted_email: 'encrypted:user@example.com',
                         encrypted_payload: 'encrypted:payload',
                         expires_at: 28.days.from_now)
    end

    describe 'happy paths' do
      before :each do
        save_return
        magic_link
      end

      it 'returns encrypted payload from save and return record' do
        post :magic_link, params: { service_slug: 'service-slug' },
                          body: json_hash.to_json

        expect(JSON.parse(response.body)).to eql({ 'encrypted_details' => 'encrypted:payload' })
      end

      it 'marks magic link as used' do
        expect do
          post :magic_link, params: { service_slug: 'service-slug' },
                            body: json_hash.to_json
        end.to change { magic_link.reload.validity }.from('valid').to('used')
      end
    end

    describe 'sad paths' do
      context 'when magic link does not exist' do
        let(:json_hash) do
          { 'magiclink': 'i-do-not-exist' }
        end

        it 'returns 404 with error' do
          post :magic_link, params: { service_slug: 'service-slug' },
                            body: json_hash.to_json

          expect(response.status).to eql(404)
          expect(JSON.parse(response.body)).to eql({ 'code' => 404, 'name' => 'invalid.link' })
        end
      end

      context 'when magic link is used' do
        let(:magic_link) do
          MagicLink.create!(service_slug: 'service-slug',
                            encrypted_email: 'encrypted:user@example.com',
                            validity: 'used',
                            expires_at: 24.hours.from_now)
        end

        before :each do
          magic_link
        end

        it 'returns 400 with error' do
          post :magic_link, params: { service_slug: 'service-slug' },
                            body: json_hash.to_json

          expect(response.status).to eql(400)
          expect(JSON.parse(response.body)).to eql({ 'code' => 400, 'name' => 'used.link' })
        end
      end

      context 'when magic link has expired' do
        let(:magic_link) do
          MagicLink.create!(service_slug: 'service-slug',
                            encrypted_email: 'encrypted:user@example.com',
                            expires_at: 10.hours.ago)
        end

        before :each do
          magic_link
        end

        it 'returns 400 with error' do
          post :magic_link, params: { service_slug: 'service-slug' },
                            body: json_hash.to_json

          expect(response.status).to eql(400)
          expect(JSON.parse(response.body)).to eql({ 'code' => 400, 'name' => 'expired.link' })
        end
      end

      context 'when no associated save and return record' do
        before :each do
          magic_link
        end

        it 'returns 500 with error' do
          post :magic_link, params: { service_slug: 'service-slug' },
                            body: json_hash.to_json

          expect(response.status).to eql(500)
          expect(JSON.parse(response.body)).to eql({ 'code' => 500, 'name' => 'missing.savereturn' })
        end
      end
    end
  end
end
