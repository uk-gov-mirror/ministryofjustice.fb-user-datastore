require 'swagger_helper'

RSpec.describe 'save and return record' do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:disable_jwt?).and_return(true)
  end

  path '/service/{service_slug}/savereturn/create' do
    post 'create save and return record for user' do
      consumes 'application/json'

      parameter name: :service_slug, in: :path, schema: {
        type: :string,
        required: true
      }

      parameter name: :json, in: :body, required: true, schema: {
        type: :object,
        properties: {
          encrypted_email: { type: :string, example: 'encrypted:user@example.com' },
          encrypted_details: { type: :string, example: 'encrypted:payload' },
          email: {
            type: :object,
            properties: {
              to: { type: :string, example: 'user@example.com' },
              subject: { type: :string, example: 'subject goes here' },
              body: { type: :string, example: 'body goes here' },
              template_name: { type: :string, example: 'name-of-template' }
            }
          }
        }
      }

      response '201', 'save and return record created' do
        let(:service_slug) { 'service-slug' }
        let(:json) do
          {
            encrypted_email: 'encrypted:user@example.com',
            encrypted_details: 'encrypted:payload',
            email: {
              to: 'user@example.com',
              subject: 'subject goes here',
              body: 'body goes here',
              template_name: 'name-of-template'
            }
          }
        end

        examples 'application/json' => {}

        run_test!
      end

      response '200', 'save and return record updated' do
        let(:service_slug) { 'service-slug' }
        let(:json) do
          {
            encrypted_email: 'encrypted:user@example.com',
            encrypted_details: 'encrypted:payload'
          }
        end

        before :each do
          SaveReturn.create!(service_slug: service_slug,
                             encrypted_email: json[:encrypted_email],
                             encrypted_payload: json[:encrypted_details])
        end

        examples 'application/json' => {}

        run_test!
      end
    end
  end

  path '/service/{service_slug}/savereturn/delete' do
    delete 'delete save and return record' do
      consumes 'application/json'

      parameter name: :service_slug, in: :path, schema: {
        type: :string,
        required: true
      }

      parameter name: :json, in: :body, required: true, schema: {
        type: :object,
        properties: {
          encrypted_email: { type: :string, required: true, example: 'user@example.com' },
        },
      }

      response '200', 'save and return record deleted' do
        let(:service_slug) { 'service-slug' }
        let(:json) do
          {
            encrypted_email: 'encrypted:user@example.com',
          }
        end

        before :each do
          SaveReturn.create!(service_slug: service_slug,
                             encrypted_email: json[:encrypted_email],
                             encrypted_payload: 'encrypted:payload')
        end

        run_test!
      end
    end
  end
end
