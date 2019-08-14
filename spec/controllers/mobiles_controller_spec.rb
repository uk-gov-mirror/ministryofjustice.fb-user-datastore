require 'rails_helper'

RSpec.describe MobilesController, type: :controller do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:verify_token!)
    request.env['CONTENT_TYPE'] = 'application/json'
  end

  let(:service_slug) { 'my-service' }

  describe 'POST /service/:service_slug/savereturn/mobile/add' do
    let(:json_hash) do
      {
        encrypted_email: 'encryptedEmail',
        encrypted_details: 'encryptedDetails',
        duration: '30'
      }
    end

    let(:post_request) do
      post :add, params: { service_slug: service_slug }, body: json_hash.to_json
    end

    context 'when the mobile record does not exist' do
      it 'persists the record' do
        expect do
          post_request
        end.to change(Mobile, :count).by(1)
      end

      it 'returns a 201 status' do
        post_request
        expect(response).to have_http_status(201)
      end

      it 'returns an empty json object' do
        post_request
        record = Mobile.last
        expect(JSON.parse(response.body)).to eql({ 'code' => record.code })
      end

      it 'sets record values correctly' do
        post_request
        record = Mobile.last

        expect(record.encrypted_email).to eq(request.parameters[:encrypted_email])
        expect(record.service_slug).to eq('my-service')
        expect(record.encrypted_payload).to eq(request.parameters[:encrypted_details])
        expect(record.expires_at).to_not be_blank
        expect(record.code).to_not be_blank
        expect(record.code.size).to eql(5)
        expect(record.code).to match(/\A\d{5}\z/)
        expect(record.validity).to eq('valid')
      end
    end

    context 'when the mobile record already exists' do
      let(:json_hash) do
        {
          encrypted_email: 'encryptedEmail',
          encrypted_details: 'encryptedDetails',
          duration: '30'
        }
      end

      let(:post_request) do
        post :add, params: { service_slug: service_slug },
                      body: json_hash.to_json
      end

      it "marks old record as 'superseded'" do
        mobile_record = Mobile.create!(service_slug: 'my-service',
                                       encrypted_email: 'encryptedEmail',
                                       encrypted_payload: 'encryptedDetails',
                                       expires_at: Time.now + 30.minutes,
                                       code: '22234',
                                       validity: 'valid')
        post_request
        expect(mobile_record.reload.validity).to eq('superseded')
      end

      it 'persists the new record' do
        expect do
          post_request
        end.to change(Mobile, :count).by(1)
      end

      it 'returns an empty json object' do
        post_request
        record = Mobile.order(created_at: :desc).first
        expect(JSON.parse(response.body)).to eql({ 'code' => record.code })
      end

      it 'sets record values correctly' do
        post_request
        record = Mobile.last

        expect(record.encrypted_email).to eq(request.parameters[:encrypted_email])
        expect(record.service_slug).to eq('my-service')
        expect(record.encrypted_payload).to eq(request.parameters[:encrypted_details])
        expect(record.expires_at).to_not be_blank
        expect(record.code).to_not be_blank
        expect(record.validity).to eq('valid')
      end
    end

    context 'with incorrect mobile data' do
      context 'without an encrypted email' do
        let(:json_hash) do
          {
            encrypted_email: nil,
            encrypted_details: 'encryptedDetails',
            duration: '30'
          }
        end

        it 'renders an unavailable error' do
          post_request
          expect(response).to have_http_status(503)
        end
      end

      context 'without encrypted details' do
        let(:json_hash) do
          {
            encrypted_email: 'encryptedEmail',
            encrypted_details: nil,
            duration: '30'
          }
        end

        it 'renders an unavailable error' do
          post_request
          expect(response).to have_http_status(503)
        end
      end
    end
  end

  describe 'POST /service/:service_slug/savereturn/mobile/confirm' do
    let(:service_slug) { 'my-form' }
    let(:json_hash) do
      {
        encrypted_email: 'encrypted:user@example.com',
        code: '12345'
      }
    end

    let(:post_request) do
      post :validate, params: { service_slug: service_slug },
                     body: json_hash.to_json
    end

    context 'code is correct' do
      let!(:record) do
        Mobile.create!(service_slug: service_slug,
                       encrypted_email: 'encrypted:user@example.com',
                       encrypted_payload: 'encrypted:payload',
                       expires_at: 2.days.from_now,
                       code: '12345',
                       validity: 'valid')
      end

      it 'returns 200' do
        post_request
        expect(response).to be_ok
      end

      it 'marks code as used' do
        expect do
          post_request
        end.to change { record.reload.validity }.from('valid').to('used')
      end

      it 'returns encrypted_details' do
        post_request
        expect(JSON.parse(response.body)).to eql({ "encrypted_details" => record.encrypted_payload })
      end
    end

    context 'when code is wrong' do
      let!(:record) do
        Mobile.create!(service_slug: service_slug,
                       encrypted_email: 'encrypted:user@example.com',
                       encrypted_payload: 'encrypted:payload',
                       expires_at: 2.days.from_now,
                       code: '12345',
                       validity: 'valid')
      end

      let(:json_hash) do
        {
          encrypted_email: 'encrypted:user@example.com',
          code: '00000'
        }
      end

      it 'returns 401' do
        post_request
        expect(response.status).to eql(401)
      end
    end

    context 'when no code exists' do
      it 'returns 401' do
        post_request
        expect(response.status).to eql(401)
      end
    end

    context 'when code has expired' do
      let!(:record) do
        Mobile.create!(service_slug: service_slug,
                       encrypted_email: 'encrypted:user@example.com',
                       encrypted_payload: 'encrypted:payload',
                       expires_at: 2.days.ago,
                       code: '12345',
                       validity: 'valid')
      end

      let(:json_hash) do
        {
          encrypted_email: 'encrypted:user@example.com',
          code: '12345'
        }
      end

      it 'returns 401' do
        post_request
        expect(response.status).to eql(401)
        expect(JSON.parse(response.body)['name']).to eql('code.expired')
        expect(JSON.parse(response.body)['code']).to eql(401)
      end
    end

    context 'when code has been used' do
      let!(:record) do
        Mobile.create!(service_slug: service_slug,
                       encrypted_email: 'encrypted:user@example.com',
                       encrypted_payload: 'encrypted:payload',
                       expires_at: 2.days.from_now,
                       code: '12345',
                       validity: 'used')
      end

      let(:json_hash) do
        {
          encrypted_email: 'encrypted:user@example.com',
          code: '12345'
        }
      end

      it 'returns 401' do
        post_request
        expect(response.status).to eql(401)
        expect(JSON.parse(response.body)['name']).to eql('code.used')
        expect(JSON.parse(response.body)['code']).to eql(401)
      end
    end

    context 'when code has been superseded' do
      let!(:record) do
        Mobile.create!(service_slug: service_slug,
                       encrypted_email: 'encrypted:user@example.com',
                       encrypted_payload: 'encrypted:payload',
                       expires_at: 2.days.from_now,
                       code: '12345',
                       validity: 'superseded')
      end

      let(:json_hash) do
        {
          encrypted_email: 'encrypted:user@example.com',
          code: '12345'
        }
      end

      it 'returns 401' do
        post_request
        expect(response.status).to eql(401)
        expect(JSON.parse(response.body)['name']).to eql('code.superseded')
        expect(JSON.parse(response.body)['code']).to eql(401)
      end
    end
  end
end
