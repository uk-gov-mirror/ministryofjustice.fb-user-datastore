require 'rails_helper'

RSpec.describe MobilesController, type: :controller do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:verify_token!)
    request.env['CONTENT_TYPE'] = 'application/json'
  end

  let(:service_slug) { 'my-service' }

  describe 'POST /service/:service_slug/savereturn/mobile/add' do
    context 'when the mobile record does not exist' do
      let(:post_request) do
        post :create, params: { service_slug: service_slug,
                                mobile: '07777 111 222',
                                encrypted_email: 'encryptedEmail',
                                encrypted_details: 'encryptedDetails',
                                duration: '30' }
      end

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
        expect(response.body).to eql('{}')
      end

      it 'sets record values correctly' do
        post_request
        record = Mobile.last

        expect(record.mobile).to eq(request.parameters[:mobile])
        expect(record.encrypted_email).to eq(request.parameters[:encrypted_email])
        expect(record.service_slug).to eq('my-service')
        expect(record.encrypted_payload).to eq(request.parameters[:encrypted_details])
        expect(record.expires_at).to_not be_blank
        expect(record.code).to_not be_blank
        expect(record.validity).to eq('valid')
      end
    end
  end
end
