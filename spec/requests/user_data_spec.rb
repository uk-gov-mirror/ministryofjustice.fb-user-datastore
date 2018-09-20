require 'rails_helper'

describe 'UserData API', type: :request do
  let(:parsed_body) { JSON.parse(response.body) }
  let(:headers) {
    {
      'content-type' => 'application/json'
    }
  }

  describe 'a GET request' do
    before do
      get url, headers: headers
    end

    context 'to /service/:service_slug/user/:user_identifier' do
      let(:slug) { 'my-service' }
      let(:user_identifier) { '12345678' }
      let(:url) { "/service/#{slug}/user/#{user_identifier}" }

      # it_behaves_like 'a JWT-authenticated method', :get, '/service/:service_slug/user/:user_identifier', {}

      context 'with a valid token' do
        let(:token) { valid_token }

        # it_behaves_like 'a JSON-only API', :get, '/service/:service_slug/:user/:user_identifier'

        context 'when the user data exists' do
          let(:user_data) { create(:user_data) }
          let(:user_identifier) { user_data.user_identifier }

          describe 'the response' do
            it 'has status 200' do
              expect(response).to have_http_status(200)
            end

            it 'has JSON content-type' do
              expect(response.content_type).to eq("application/json")
            end

            it 'is valid JSON' do
              expect { json }.to_not raise_error
            end

            describe 'the timestamp key' do
              # have to work around formatting and precision issues here
              it 'is set to the updated_at value of the user data' do
                expect( DateTime.parse(json['timestamp']).to_s(:iso_8601) )\
                  .to eq(user_data.updated_at.to_datetime.to_s(:iso_8601))
              end

              it 'is formatted as ISO-8601' do
                expect{ Time.iso8601(json['timestamp']) }.to_not raise_error
              end
            end

            describe 'the payload key' do
              it 'contains the payload as it is in the database' do
                expect(json['payload']).to eq(user_data.payload)
              end
            end

          end
        end
        context 'when the user data does not exist' do
          describe 'the response' do
            it 'has status 404' do
              expect(response).to have_http_status(404)
            end

            describe 'body' do
              it 'has a json errors key' do
                expect(json['errors']).to_not be_nil
              end
            end
          end
        end
      end
    end
  end

  describe 'POST /service/:service_slug/:user/:user_identifier' do

  end

end
