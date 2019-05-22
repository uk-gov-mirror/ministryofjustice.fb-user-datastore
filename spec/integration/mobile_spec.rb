require 'swagger_helper'
require 'securerandom'

RSpec.describe 'mobile' do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:disable_jwt?).and_return(true)
    stub_request(:post, "http://localhost:3000/sms").to_return(status: 201)
  end

  path '/service/{service_slug}/savereturn/mobile/add' do
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

        examples 'application/json' => {}

        run_test!
      end
    end
  end
end
