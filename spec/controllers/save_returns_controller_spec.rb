require 'rails_helper'

RSpec.describe SaveReturnsController, type: :controller do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:verify_token!)
    request.env['CONTENT_TYPE'] = 'application/json'
  end

  describe 'POST #create' do
    let(:json_hash) do
      {
        email: 'foo@example.com',
        user_details: 'foo',
      }
    end

    describe 'happy path' do
      it 'creates record' do
        expect do
          post :create, params: { service_slug: 'service-slug' },
                        body: json_hash.to_json

        end.to change(SaveReturn, :count).by(1)
      end

      it 'returns 201 created' do
        post :create, params: { service_slug: 'service-slug' },
                      body: json_hash.to_json

        expect(response.status).to eql(201)
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
      before :each do
        SaveReturn.create!(encrypted_email: json_hash[:email],
                           encrypted_payload: json_hash[:user_details],
                           service: 'service-slug')
      end

      it 'does not persist another record' do
        expect do
          post :create, params: { service_slug: 'service-slug' },
                        body: json_hash.to_json

        end.to_not change(SaveReturn, :count)
      end

      it 'returns 200' do
        post :create, params: { service_slug: 'service-slug' },
                      body: json_hash.to_json

        expect(response.status).to eql(200)
      end
    end
  end
end
