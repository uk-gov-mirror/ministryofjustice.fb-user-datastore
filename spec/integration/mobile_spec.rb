require 'swagger_helper'
require 'securerandom'

RSpec.describe 'mobile' do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:disable_jwt?).and_return(true)
  end

  path '/service/{service_slug}/savereturn/setup/mobile/add' do
    post 'send confirmation sms to user' do
      consumes 'application/json'

      parameter name: :service_slug, in: :path, schema: {
        type: :string,
        required: true
      }

      parameter name: :json, in: :body, required: true, schema: {
        type: :object,
        properties: {
          sms: {
            type: :object,
            properties: {
              to: { type: :string, example: '07123456789' },
              body: { type: :string, example: 'text message goes here' },
              template_name: { type: :string, example: 'sms.generic' }
            }
          },
          encrypted_email: { type: :string, example: 'encrypted:user@example.com' },
          encrypted_details: { type: :string, example: 'encrypted:payload' },
          duration: { type: :integer, required: false, default: 30, example: 60 },
        }
      }

      response '201', 'mobile confirmation created' do
        let(:service_slug) { 'service-slug' }
        let(:json) do
          {
            sms: {
              to: '071234567890',
              body: 'body goes here',
              template_name: 'name-of-template'
            },
            encrypted_email: 'encrypted:user@example.com',
            encrypted_details: 'encrypted:payload'
          }
        end

        examples 'application/json' => { code: '12345' }

        run_test!
      end
    end
  end

  path '/service/{service_slug}/savereturn/setup/mobile/validate' do
    post 'confirm sms code' do
      consumes 'application/json'

      parameter name: :service_slug, in: :path, schema: {
        type: :string,
        required: true
      }

      parameter name: :json, in: :body, required: true, schema: {
        type: :object,
        properties: {
          encrypted_email: { type: :string, example: 'encrypted:user@example.com' },
          code: { type: :string, required: true, example: '12345' },
        }
      }

      response '200', 'mobile code correct' do
        let(:service_slug) { 'service-slug' }
        let(:json) do
          {
            encrypted_email: 'encrypted:user@example.com',
            code: '12345'
          }
        end
        let!(:record) do
          Mobile.create!(service_slug: service_slug,
                         encrypted_email: 'encrypted:user@example.com',
                         encrypted_payload: 'encrypted:payload',
                         expires_at: 2.days.from_now,
                         code: '12345',
                         validity: 'valid')
        end

        examples 'application/json' => { encrypted_details: 'encrypted:payload' }

        run_test!
      end

      response '401', 'mobile code incorrect' do
        let(:service_slug) { 'service-slug' }
        let(:json) do
          {
            encrypted_email: 'encrypted:user@example.com',
            code: '12345'
          }
        end

        examples 'application/json' => {}

        run_test!
      end
    end
  end
end
