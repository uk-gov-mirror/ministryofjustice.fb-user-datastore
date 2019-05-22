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
        sms: {
          to: '07777111222',
          body: 'body goes here',
          template_name: 'foo'
        },
        encrypted_email: 'encryptedEmail',
        encrypted_details: 'encryptedDetails',
        duration: '30'
      }
    end

    before do
      stub_request(:post, "http://localhost:3000/sms").to_return(status: 201)
    end

    let(:post_request) do
      post :create, params: { service_slug: service_slug }, body: json_hash.to_json
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
        expect(response.body).to eql('{}')
      end

      it 'sets record values correctly' do
        post_request
        record = Mobile.last

        expect(record.mobile).to eq(json_hash[:sms][:to])
        expect(record.encrypted_email).to eq(request.parameters[:encrypted_email])
        expect(record.service_slug).to eq('my-service')
        expect(record.encrypted_payload).to eq(request.parameters[:encrypted_details])
        expect(record.expires_at).to_not be_blank
        expect(record.code).to_not be_blank
        expect(record.validity).to eq('valid')
      end

      it 'makes api call to send text message' do
        mock_sender = double('sender')
        expect(SmsSender).to receive(:new).and_return(mock_sender)
        expect(mock_sender).to receive(:call)

        post_request
      end
    end

    context 'when the mobile record already exists' do
      let(:json_hash) do
        {
          sms: {
            to: '07777111222',
            body: 'body goes here',
            template_name: 'foo'
          },
          encrypted_email: 'encryptedEmail',
          encrypted_details: 'encryptedDetails',
          duration: '30'
        }
      end

      let(:post_request) do
        post :create, params: { service_slug: service_slug },
                      body: json_hash.to_json
      end

      it "marks old record as 'superseded'" do
        mobile_record = Mobile.create!(service_slug: 'my-service',
                                       mobile: '07777111222',
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
        expect(response.body).to eql('{}')
      end

      it 'sets record values correctly' do
        post_request
        record = Mobile.last

        expect(record.mobile).to eq(json_hash[:sms][:to])
        expect(record.encrypted_email).to eq(request.parameters[:encrypted_email])
        expect(record.service_slug).to eq('my-service')
        expect(record.encrypted_payload).to eq(request.parameters[:encrypted_details])
        expect(record.expires_at).to_not be_blank
        expect(record.code).to_not be_blank
        expect(record.validity).to eq('valid')
      end
    end

    context 'when send sms api call fails' do
      before :each do
        mock_sender = double('sender')
        allow(SmsSender).to receive(:new).and_return(mock_sender)
        allow(mock_sender).to receive(:call).and_raise(SmsSender::OperationFailed)
      end

      it 'does not save mobile record' do
        expect do
          post_request
        end.to_not change(Mobile, :count)
      end

      it 'returns a 500' do
        post_request
        expect(response.status).to eql(500)
      end
    end
  end
end
