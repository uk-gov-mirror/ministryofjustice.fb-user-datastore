require 'rails_helper'

RSpec.describe EmailSigninsController do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:authenticate)
    request.env['CONTENT_TYPE'] = 'application/json'
  end

  describe 'POST #add' do
    let(:json_hash) do
      { encrypted_email: 'encrypted:user@example.com' }
    end

    let(:do_post!) do
      post :add, params: { service_slug: 'service-slug' },
                   body: json_hash.to_json
    end

    describe 'happy path' do
      before :each do
        SaveReturn.create!(service_slug: 'service-slug',
                           encrypted_email: 'encrypted:user@example.com',
                           encrypted_payload: 'encrypted:payload',
                           expires_at: 28.days.from_now)
      end

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
      before :each do
        SaveReturn.create!(service_slug: 'service-slug',
                           encrypted_email: 'encrypted:user@example.com',
                           encrypted_payload: 'encrypted:payload',
                           expires_at: 28.days.from_now)
      end

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

    context 'when there is no associated save and return record' do
      it 'does not create a magic link record' do
        expect do
          do_post!
        end.to_not change(MagicLink, :count)
      end

      it 'returns 401' do
        do_post!

        expect(response).to be_unauthorized
        expect(JSON.parse(response.body)).to eql({ 'code' => 401, 'name' => 'email.missing' })
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
        post :validate, params: { service_slug: 'service-slug' },
                          body: json_hash.to_json

        expect(JSON.parse(response.body)).to eql({ 'encrypted_details' => 'encrypted:payload' })
      end

      it 'marks magic link as used' do
        expect do
          post :validate, params: { service_slug: 'service-slug' },
                            body: json_hash.to_json
        end.to change { magic_link.reload.validity }.from('valid').to('used')
      end
    end

    describe 'sad paths' do
      context 'when magic link does not exist' do
        let(:json_hash) do
          { 'magiclink': 'i-do-not-exist' }
        end

        it 'returns 401 with error' do
          post :validate, params: { service_slug: 'service-slug' },
                            body: json_hash.to_json

          expect(response.status).to eql(401)
          expect(JSON.parse(response.body)).to eql({ 'code' => 401, 'name' => 'token.invalid' })
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

        it 'returns 401 with error' do
          post :validate, params: { service_slug: 'service-slug' },
                            body: json_hash.to_json

          expect(response.status).to eql(401)
          expect(JSON.parse(response.body)).to eql({ 'code' => 401, 'name' => 'token.used' })
        end
      end

      context 'when magic link is superseded' do
        let(:magic_link) do
          MagicLink.create!(service_slug: 'service-slug',
                            encrypted_email: 'encrypted:user@example.com',
                            validity: 'superseded',
                            expires_at: 24.hours.from_now)
        end

        before :each do
          magic_link
        end

        it 'returns 401 with error' do
          post :validate, params: { service_slug: 'service-slug' },
                            body: json_hash.to_json

          expect(response.status).to eql(401)
          expect(JSON.parse(response.body)).to eql({ 'code' => 401, 'name' => 'token.superseded' })
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

        it 'returns 401 with error' do
          post :validate, params: { service_slug: 'service-slug' },
                            body: json_hash.to_json

          expect(response.status).to eql(401)
          expect(JSON.parse(response.body)).to eql({ 'code' => 401, 'name' => 'token.expired' })
        end
      end

      context 'when in incorrect validaity' do
        let!(:magic_link) do
          MagicLink.create!(service_slug: 'service-slug',
                            encrypted_email: 'encrypted:user@example.com',
                            expires_at: 24.hours.from_now,
                            validity: 'foo')
        end

        let!(:save_return) do
          SaveReturn.create!(service_slug: 'service-slug',
                             encrypted_email: 'encrypted:user@example.com',
                             encrypted_payload: 'encrypted:payload',
                             expires_at: 28.days.from_now)
        end

        it 'returns 401 with error' do
          post :validate, params: { service_slug: 'service-slug' },
                            body: json_hash.to_json

          expect(response.status).to eql(401)
          expect(JSON.parse(response.body)).to eql({ 'code' => 401, 'name' => 'token.invalid' })
        end
      end

      context 'when no associated save and return record' do
        before :each do
          magic_link
        end

        it 'returns 401 with error' do
          post :validate, params: { service_slug: 'service-slug' },
                            body: json_hash.to_json

          expect(response.status).to eql(401)
          expect(JSON.parse(response.body)).to eql({ 'code' => 401, 'name' => 'token.invalid' })
        end
      end
    end
  end
end
