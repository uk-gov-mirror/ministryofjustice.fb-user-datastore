require 'swagger_helper'
require 'securerandom'

RSpec.describe 'email signin' do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:disable_jwt?).and_return(true)
  end

  path '/service/{service_slug}/savereturn/signin/email/add' do
    post 'send signin email to user' do
      consumes 'application/json'

      parameter name: :service_slug, in: :path, schema: {
        type: :string,
        required: true
      }

      parameter name: :json, in: :body, required: true, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'user@example.com' },
          encrypted_email: { type: :string, example: 'encrypted:user@example.com' },
          encrypted_details: { type: :string, example: 'encrypted:payload' },
          duration: { type: :integer, required: false, default: 120, example: 120 },
        }
      }

      response '201', 'email confirmation created' do
        let(:service_slug) { 'service-slug' }
        let(:json) do
          {
            encrypted_email: 'encrypted:user@example.com',
            encrypted_details: 'encrypted:payload',
          }
        end

        examples 'application/json' => { token: 'this-is-a-guid' }

        run_test!
      end
    end
  end

  path '/service/{service_slug}/savereturn/signin/email/validate' do
    post 'confirm magiclink' do
      consumes 'application/json'

      parameter name: :service_slug, in: :path, schema: {
        type: :string,
        required: true
      }

      parameter name: :json, in: :body, required: true, schema: {
        type: :object,
        properties: {
          magiclink: { type: :string, required: true, example: "352ded7d-405b-44d5-b825-de8f39fd5869" },
        },
      }

      response '200', 'magiclink correct and processed' do
        let(:uuid) { "352ded7d-405b-44d5-b825-de8f39fd5869" }
        let(:service_slug) { 'service-slug' }
        let(:json) do
          {
            magiclink: uuid
          }
        end

        before :each do
          SaveReturn.create!(service_slug: service_slug,
                             encrypted_email: 'encrypted:user@example.com',
                             encrypted_payload: 'encrypted:payload')

          MagicLink.create!(id: uuid,
                            service_slug: service_slug,
                            expires_at: 2.hours.from_now,
                            encrypted_email: 'encrypted:user@example.com',
                            validity: 'valid')
        end

        run_test!
      end

      response '404', 'magic link not found' do
        let(:service_slug) { 'service-slug' }
        let(:json) do
          {
            email: 'user@example.com',
            encrypted_email: 'encrypted:user@example.com',
            encrypted_details: 'encrypted:payload'
          }
        end

        run_test!
      end

      response '400', 'magiclink already used or expired' do
        let(:uuid) { SecureRandom.uuid }
        let(:service_slug) { 'service-slug' }
        let(:json) do
          {
            magiclink: uuid
          }
        end

        before :each do
          MagicLink.create!(id: uuid,
                            service_slug: service_slug,
                            expires_at: 2.hours.from_now,
                            encrypted_email: 'encrypted:user@example.com',
                            validity: 'used')
        end

        run_test!
      end
    end
  end
end
