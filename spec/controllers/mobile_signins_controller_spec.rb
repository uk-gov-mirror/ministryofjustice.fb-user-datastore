require 'rails_helper'

RSpec.describe MobileSigninsController do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:verify_token!)
    request.env['CONTENT_TYPE'] = 'application/json'
  end

  describe 'POST #add' do
    let(:json_hash) do
      {
        encrypted_email: 'encrypted:user@example.com',
      }
    end

    let(:do_post!) do
      post :add, params: { service_slug: 'service-slug' },
                 body: json_hash.to_json
    end

    describe 'happy path' do
      it 'creates code record' do
        expect do
          do_post!
        end.to change(Code, :count).by(1)
      end

      it 'persists code record correctly' do
        do_post!

        record = Code.last

        expect(record.service_slug).to eql('service-slug')
        expect(record.encrypted_email).to eql('encrypted:user@example.com')
        expect(record.expires_at).to be_within(2.hours).of(2.hours.from_now)
        expect(record.validity).to eql('valid')
      end

      it 'responds with code' do
        do_post!
        record = Code.last

        expect(JSON.parse(response.body)).to eql({"code" => record.code})
      end

      context 'with custom duration' do
        let(:json_hash) do
          {
            encrypted_email: 'encrypted:user@example.com',
            duration: 10
          }
        end

        it 'honours duration' do
          do_post!
          record = Code.last

          expect(record.expires_at).to be_within(2.minutes).of(10.minutes.from_now)
        end
      end
    end

    describe 'if code for email already exists' do
      let!(:previous_code) do
        Code.create!(service_slug: 'service-slug',
                     encrypted_email: 'encrypted:user@example.com',
                     expires_at: 24.hours.from_now)
      end

      it 'marks previous records as superseded' do
        expect do
          do_post!
        end.to change { previous_code.reload.validity }.from('valid').to('superseded')
      end

      it 'creates new code record' do
        expect do
          do_post!
        end.to change(Code, :count).by(1)
      end
    end
  end

  describe 'POST #validate' do
    let(:json_hash) do
      { 'code': code.code, encrypted_email: 'encrypted:user@example.com' }
    end

    let(:code) do
      Code.create!(service_slug: 'service-slug',
                   encrypted_email: 'encrypted:user@example.com',
                   expires_at: 2.hours.from_now)
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
        code
      end

      it 'returns encrypted payload from save and return record' do
        post :validate, params: { service_slug: 'service-slug' },
                        body: json_hash.to_json

        expect(JSON.parse(response.body)).to eql({ 'encrypted_details' => 'encrypted:payload' })
      end

      it 'marks code as used' do
        expect do
          post :validate, params: { service_slug: 'service-slug' },
                            body: json_hash.to_json
        end.to change { code.reload.validity }.from('valid').to('used')
      end
    end

    describe 'sad paths' do
      context 'when code does not exist' do
        let(:json_hash) do
          { 'code': 'i-do-not-exist' }
        end

        it 'returns 401 with error' do
          post :validate, params: { service_slug: 'service-slug' },
                            body: json_hash.to_json

          expect(response.status).to eql(401)
          expect(JSON.parse(response.body)).to eql({ 'code' => 401, 'name' => 'code.invalid' })
        end
      end

      context 'when code is used' do
        let(:code) do
          Code.create!(service_slug: 'service-slug',
                       encrypted_email: 'encrypted:user@example.com',
                       validity: 'used',
                       expires_at: 24.hours.from_now)
        end

        before :each do
          code
        end

        it 'returns 401 with error' do
          post :validate, params: { service_slug: 'service-slug' },
                            body: json_hash.to_json

          expect(response.status).to eql(401)
          expect(JSON.parse(response.body)).to eql({ 'code' => 401, 'name' => 'code.used' })
        end
      end

      context 'when code has expired' do
        let(:code) do
          Code.create!(service_slug: 'service-slug',
                       encrypted_email: 'encrypted:user@example.com',
                       expires_at: 10.hours.ago)
        end

        before :each do
          code
        end

        it 'returns 401 with error' do
          post :validate, params: { service_slug: 'service-slug' },
                            body: json_hash.to_json

          expect(response.status).to eql(401)
          expect(JSON.parse(response.body)).to eql({ 'code' => 401, 'name' => 'code.expired' })
        end
      end

      context 'when code is superseded' do
        let!(:code) do
          Code.create!(service_slug: 'service-slug',
                       encrypted_email: 'encrypted:user@example.com',
                       expires_at: 10.hours.from_now,
                       validity: 'superseded')
        end

        it 'returns 401 with error' do
          post :validate, params: { service_slug: 'service-slug' },
                            body: json_hash.to_json

          expect(response.status).to eql(401)
          expect(JSON.parse(response.body)).to eql({ 'code' => 401, 'name' => 'code.superseded' })
        end
      end

      context 'when code is in other validity state' do
        let!(:code) do
          Code.create!(service_slug: 'service-slug',
                       encrypted_email: 'encrypted:user@example.com',
                       expires_at: 10.hours.from_now,
                       validity: 'foo')
        end

        it 'returns 401 with error' do
          post :validate, params: { service_slug: 'service-slug' },
                            body: json_hash.to_json

          expect(response.status).to eql(401)
          expect(JSON.parse(response.body)).to eql({ 'code' => 401, 'name' => 'code.invalid' })
        end
      end

      context 'when no associated save and return record' do
        before :each do
          code
        end

        it 'returns 500 with error' do
          post :validate, params: { service_slug: 'service-slug' },
                            body: json_hash.to_json

          expect(response.status).to eql(500)
          expect(JSON.parse(response.body)).to eql({ 'code' => 500, 'name' => 'missing.savereturn' })
        end
      end
    end
  end
end
