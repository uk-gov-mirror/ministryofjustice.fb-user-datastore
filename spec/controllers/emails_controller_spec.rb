require 'rails_helper'

RSpec.describe EmailsController, type: :controller do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:verify_token!)
    request.env['CONTENT_TYPE'] = 'application/json'
  end

  let(:service_slug) { 'my-service' }

  describe 'POST /service/:service/savereturn/email/add' do
    let(:post_request) do
      post :create, params: { service_slug: service_slug },
                    body: json_hash.to_json
    end

    let(:json_hash) do
      {
        encrypted_email: 'encrypted:jane-doe@example.com',
        encrypted_details: '64c0b8afa7e93d51c1fc5fe82cac4a690927ee1aa5883b985',
        duration: 30
      }
    end

    context 'with a valid JSON body' do
      context 'when the email records already exist' do
        let(:existing_record1) do
          Email.create!(id: '5db4f4e3-71ef-4784-a03a-2f2a490174f2',
                        encrypted_email: 'encrypted:jane-doe@example.com',
                        service_slug: service_slug,
                        encrypted_payload: '64c0b8afa7e93d51c1fc5fe82cac4a690927ee1aa5883b985',
                        expires_at: Time.now + 20.minutes,
                        validity: 'valid')
        end

        let(:existing_record2) do
          Email.create!(id: '5db4f4e3-71ef-4784-a03a-2f2a490174f3',
                        encrypted_email: 'encrypted:jane-doe@example.com',
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
          expect(Email.where(encrypted_email: 'encrypted:jane-doe@example.com').count).to eq(3)
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

  describe 'POST #confirm' do
    context 'happy path' do
      let(:email) do
        Email.create!(encrypted_email: 'encrypted:user@example.com',
                      service_slug: 'service-slug',
                      encrypted_payload: 'foo',
                      expires_at: 28.days.from_now,
                      validity: 'valid')
      end

      before :each do
        email
      end

      it 'returns email_details' do
        post :confirm, params: { service_slug: 'service-slug', email_token: email.id }

        expect(response).to be_successful
        expect(JSON.parse(response.body)).to eql({ 'encrypted_details' => 'foo' })
      end

      it 'marks record as used' do
        expect do
          post :confirm, params: { service_slug: 'service-slug', email_token: email.id }
        end.to change { email.reload.validity }.from('valid').to('used')
      end
    end

    context 'when email token cannot be found' do
      it 'returns link invalid' do
        post :confirm, params: { service_slug: 'service-slug', email_token: 'idontexist' }

        expect(response.status).to eql(404)
        expect(JSON.parse(response.body)).to eql({ 'code' => 404, 'name' => 'invalid.link' })
      end
    end

    context 'when link has expired' do
      let(:email) do
        Email.create!(encrypted_email: 'encrypted:user@example.com',
                      service_slug: 'service-slug',
                      encrypted_payload: 'foo',
                      expires_at: 10.days.ago,
                      validity: 'valid')
      end

      it 'returns expired' do
        post :confirm, params: { service_slug: email.service_slug, email_token: email.id }

        expect(response.status).to eql(410)
        expect(JSON.parse(response.body)).to eql({ 'code' => 410, 'name' => 'expired.link' })
      end
    end

    context 'when link has already been used' do
      let(:email) do
        Email.create!(encrypted_email: 'encrypted:user@example.com',
                      service_slug: 'service-slug',
                      encrypted_payload: 'foo',
                      expires_at: 10.days.from_now,
                      validity: 'used')
      end

      it 'returns used' do
        post :confirm, params: { service_slug: email.service_slug, email_token: email.id }

        expect(response.status).to eql(410)
        expect(JSON.parse(response.body)).to eql({ 'code' => 410, 'name' => 'used.link' })
      end
    end

    context 'when link has been superseded' do
      let(:email) do
        Email.create!(encrypted_email: 'encrypted:user@example.com',
                      service_slug: 'service-slug',
                      encrypted_payload: 'foo',
                      expires_at: 10.days.from_now,
                      validity: 'superseded')
      end

      it 'returns superseded error' do
        post :confirm, params: { service_slug: email.service_slug, email_token: email.id }

        expect(response.status).to eql(400)
        expect(JSON.parse(response.body)).to eql({ 'code' => 400, 'name' => 'superseded.link' })
      end
    end
  end
end
