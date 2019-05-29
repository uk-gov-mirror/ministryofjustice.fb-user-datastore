require 'swagger_helper'
require 'securerandom'

RSpec.describe 'mobile signin' do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:disable_jwt?).and_return(true)
  end

  path '/service/{service_slug}/savereturn/signin/mobile/add' do
    post 'send signin mobile to user' do
      consumes 'application/json'

      parameter name: :service_slug, in: :path, schema: {
        type: :string,
        required: true
      }

      parameter name: :json, in: :body, required: true, schema: {
        type: :object,
        properties: {
          encrypted_email: { type: :string, example: 'encrypted:user@example.com' }
        }
      }

      response '201', 'mobile code created' do
        let(:service_slug) { 'service-slug' }
        let(:json) do
          {
            encrypted_email: 'encrypted:user@example.com',
          }
        end

        examples 'application/json' => { code: '12345' }

        run_test!
      end
    end
  end

  path '/service/{service_slug}/savereturn/signin/mobile/validate' do
    post 'confirm magiclink' do
      consumes 'application/json'

      parameter name: :service_slug, in: :path, schema: {
        type: :string,
        required: true
      }

      parameter name: :json, in: :body, required: true, schema: {
        type: :object,
        properties: {
          encrypted_email: { type: :string, required: true, example: 'encrypted:user@example.com' },
          code: { type: :string, required: true, example: '12345' },
        },
      }

      response '200', 'code correct and processed' do
        let(:service_slug) { 'service-slug' }
        let(:json) do
          {
            encrypted_email: 'encrypted:user@example.com',
            code: '12345'
          }
        end

        before :each do
          SaveReturn.create!(service_slug: service_slug,
                             encrypted_email: 'encrypted:user@example.com',
                             encrypted_payload: 'encrypted:payload')

          Code.create!(code: '12345',
                       service_slug: service_slug,
                       expires_at: 2.hours.from_now,
                       encrypted_email: 'encrypted:user@example.com',
                       validity: 'valid')
        end

        examples 'application/json' => { encrypted_details: 'encrypted:payload' }

        run_test!
      end

      response '401', 'magic link not found' do
        let(:service_slug) { 'service-slug' }
        let(:json) do
          {
            encrypted_email: 'encrypted:user@example.com',
            code: '00000'
          }
        end

        run_test!
      end

      response '401', 'magiclink already used or expired' do
        let(:service_slug) { 'service-slug' }
        let(:json) do
          {
            encrypted_email: 'encrypted:user@example.com',
            code: '12345'
          }
        end

        before :each do
          Code.create!(code: '12345',
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
