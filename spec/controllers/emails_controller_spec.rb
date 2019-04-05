require 'rails_helper'

RSpec.describe EmailsController, type: :controller do
  before :each do
    request.env['CONTENT_TYPE'] = 'application/json'
  end

  let(:service_slug) { 'my-service' }

  describe 'POST /service/:service/savereturn/email/add' do
    let(:post_request) do
      post :create, params: { service_slug: service_slug },
                    body: params.to_json
    end

    before do
      allow_any_instance_of(ApplicationController).to receive(:verify_token!)
    end

    let(:params) do
      {
        email_for_sending: 'jane-doe@example.com',
        email_details: '64c0b8afa7e93d51c1fc5fe82cac4a690927ee1aa5883b985',
        duration: 30,
        link_template: {}
      }
    end

    context 'with a valid JSON body' do
      context 'when the email record does not exist' do
        it 'returns a 201 status' do
          post_request
          expect(response).to have_http_status(201)
        end

        it 'sets validity to `valid`' do
          post_request
          expect(Email.first.validity).to eq('valid')
        end
      end

      context 'when the email records already exist' do
        let(:existing_record1) do
          Email.create!(id: '5db4f4e3-71ef-4784-a03a-2f2a490174f2',
                        email: 'jane-doe@example.com',
                        service_slug: service_slug,
                        encrypted_payload: '64c0b8afa7e93d51c1fc5fe82cac4a690927ee1aa5883b985',
                        expires_at: Time.now + 20.minutes,
                        validity: 'valid')
        end

        let(:existing_record2) do
          Email.create!(id: '5db4f4e3-71ef-4784-a03a-2f2a490174f3',
                        email: 'jane-doe@example.com',
                        service_slug: service_slug,
                        encrypted_payload: '64c0b8afa7e93d51c1fc5fe82cac4a690927ee1aa5883b985',
                        expires_at: Time.now + 20.minutes,
                        validity: 'valid')
        end

        before do
          existing_record1
          existing_record2
          post_request
        end

        it 'there are multiple records with the same email address' do
          expect(Email.where(email: 'jane-doe@example.com').count).to eq(3)
        end

        it 'sets validity of existing record to `superseded`' do
          old_record = Email.find_by_id(existing_record1.id)
          expect(old_record.validity).to eq('superseded')
          old_record = Email.find_by_id(existing_record2.id)
          expect(old_record.validity).to eq('superseded')
        end

        it 'sets newest created record validity to `valid`' do
          new_record = Email.order(created_at: :asc).last
          expect(new_record.validity).to eq('valid')
        end

        it 'returns a 201 status' do
          expect(response).to have_http_status(201)
        end
      end

      context 'when there is an error' do
        before :each do
          allow_any_instance_of(Email).to receive(:save).and_return(false)
        end

        it 'returns a 503' do
          post_request
          expect(response).to have_http_status(503)
        end

        it 'returns error message' do
          post_request
          hash = JSON.parse(response.body)
          expect(hash['code']).to eql(503)
          expect(hash['name']).to eql('unavailable')
        end
      end
    end
  end
end
