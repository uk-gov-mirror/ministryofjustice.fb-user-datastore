require 'rails_helper'

RSpec.describe SaveReturnsController, type: :controller do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:verify_token!)
    request.env['CONTENT_TYPE'] = 'application/json'
  end

  describe 'POST #create' do
    let(:json_hash) do
      {
        encrypted_email: 'encrypted:foo@example.com',
        encrypted_details: 'encrypted:foo',
      }
    end

    describe 'happy path' do
      it 'creates record' do
        expect do
          post :create, params: { service_slug: 'service-slug' },
                        body: json_hash.to_json

        end.to change(SaveReturn, :count).by(1)
      end

      it 'returns 201 with empty json object' do
        post :create, params: { service_slug: 'service-slug' },
                      body: json_hash.to_json

        expect(response.status).to eql(201)
        expect(response.body).to eql('{}')
      end
    end

    describe 'when cant save record' do
      it 'returns 500' do
        allow(SaveReturn).to receive(:create).and_return(false)

        post :create, params: { service_slug: 'service-slug' },
                      body: json_hash.to_json

        expect(response.status).to eql(500)
      end
    end

    describe 'when creating a duplicate record' do
      let(:json_hash) do
        {
          encrypted_email: 'encrypted:foo@example.com',
          encrypted_details: 'encrypted:bar',
        }
      end

      let(:save_return) do
        SaveReturn.create!(encrypted_email: 'encrypted:foo@example.com',
                           encrypted_payload: 'encrypted:foo',
                           service: 'service-slug')
      end

      before :each do
        save_return
      end

      it 'does not persist another record' do
        expect do
          post :create, params: { service_slug: 'service-slug' },
                        body: json_hash.to_json

        end.to_not change(SaveReturn, :count)
      end

      it 'updates existing record' do
        expect do
          post :create, params: { service_slug: 'service-slug' },
                        body: json_hash.to_json

        end.to change { save_return.reload.encrypted_payload }.from('encrypted:foo').to('encrypted:bar')
      end

      it 'returns 200 with empty json object' do
        post :create, params: { service_slug: 'service-slug' },
                      body: json_hash.to_json

        expect(response.status).to eql(200)
        expect(response.body).to eql('{}')
      end
    end
  end

  describe 'DELETE #delete' do
    let(:json_hash) do
      {
        encrypted_email: 'encrypted:user@example.com',
      }
    end

    describe 'happy path' do
      let!(:save_return) do
        SaveReturn.create!(service: 'service-slug',
                           encrypted_email: 'encrypted:user@example.com',
                           encrypted_payload: 'encrypted:payload')
      end

      it 'deletes record' do
        expect do
          delete :delete, params: { service_slug: 'service-slug' },
                          body: json_hash.to_json

        end.to change(SaveReturn, :count).by(-1)
      end

      it 'returns 200 with empty json object' do
        delete :delete, params: { service_slug: 'service-slug' },
                        body: json_hash.to_json

        expect(response.status).to eql(200)
        expect(response.body).to eql('{}')
      end

      context 'when associated emails exist' do
        let!(:email) do
          Email.create!(service_slug: 'service-slug',
                        email: 'user@example.com',
                        encrypted_email: 'encrypted:user@example.com',
                        encrypted_payload: 'encrypted:payload',
                        expires_at: 2.hours.from_now)
        end

        it 'deletes them' do
          expect do
            delete :delete, params: { service_slug: 'service-slug' },
                            body: json_hash.to_json

          end.to change(Email, :count).by(-1)
        end
      end

      context 'when associated magic links exist' do
        let!(:magic_link) do
          MagicLink.create!(service: 'service-slug',
                            email: 'user@example.com',
                            encrypted_email: 'encrypted:user@example.com',
                            expires_at: 2.hours.from_now)
        end

        it 'deletes them' do
          expect do
            delete :delete, params: { service_slug: 'service-slug' },
                            body: json_hash.to_json

          end.to change(MagicLink, :count).by(-1)
        end
      end
    end
  end
end
