require 'rails_helper'

describe 'UserData API', type: :request do
  let(:headers) {
    {
      'content-type' => 'application/json'
    }
  }
  let(:service_slug) { 'my-service' }
  # NOTE: this must be a valid UUID, otherwise ActiveRecord silently
  # ignores it in an initializer
  let(:user_identifier) { SecureRandom::uuid }


  describe 'a GET request' do
    context 'to /service/:service_slug/user/:user_identifier' do
      let(:url) { "/service/#{service_slug}/user/#{user_identifier}" }

      it_behaves_like 'a JSON-only API', :get, '/service/:service_slug/user/:user_identifier'
      it_behaves_like 'a JWT-authenticated method', :get, '/service/:service_slug/user/:user_identifier', {}

      context 'with a valid token' do
        before do
          allow_any_instance_of(ApplicationController).to receive(:verify_token!)
          get url, headers: headers
        end

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
    let(:post_request) do
      post url, params: params.to_json, headers: headers
    end

    context 'to /service/:service_slug/user/:user_identifier' do
      let(:url) { "/service/#{service_slug}/user/#{user_identifier}" }

      it_behaves_like 'a JSON-only API', :get, '/service/:service_slug/user/:user_identifier'
      it_behaves_like 'a JWT-authenticated method', :get, '/service/:service_slug/user/:user_identifier', {}

      context 'with a valid token' do
        before do
          allow_any_instance_of(ApplicationController).to receive(:verify_token!)
        end

        context 'and a valid JSON body' do
          let(:encrypted_payload) { 'kdjh9s8db9s87dbosd7b0sd8b70s9d8bs98d7b9s8db' }
          let(:params) {{
            payload: encrypted_payload
          }}

          let(:matching_user_data) {
            UserData.where(
              service_slug: service_slug,
              user_identifier: user_identifier
            )
          }

          context 'when the user data does not exist' do
            it 'creates the user data' do
              expect{ post_request }.to change{ matching_user_data.count }.from(0).to(1)
            end

            it 'responds with :created status' do
              post_request
              expect(response).to have_http_status(:created)
            end

            describe 'the created_user_data' do
              let(:created_user_data) { matching_user_data.last }

              it 'has the given payload' do
                post_request
                expect(created_user_data.payload).to eq(encrypted_payload)
              end
            end
          end
          context 'when the user data exists' do
            let!(:existing_user_data) {
              UserData.create!(
                service_slug: service_slug,
                user_identifier: user_identifier,
                payload: 'existingpayload'
              )
            }

            it 'does not create new user data' do
              expect{ post_request }.to_not change{ UserData.count }
            end

            it 'updates the existing_user_data' do
              expect{ post_request }.to change{ existing_user_data.reload.payload }
              .from('existingpayload')
              .to(encrypted_payload)
            end

            it 'responds with :no_content status' do
              post_request
              expect(response).to have_http_status(:no_content)
            end
          end
        end
      end
    end
  end

  describe 'request error messages' do
    context 'exception TokenNotValidError raised' do
      before do
        allow_any_instance_of(ApplicationController).to receive(:verify_token!).and_raise(Exceptions::TokenNotValidError)
        post "/service/#{service_slug}/user/#{user_identifier}"
      end
      it 'returns a 403 status' do
        expect(response).to have_http_status(403)
      end

      it 'returns json error message' do
        expect(json['errors'].first['title']).to eq(I18n.t('error_messages.token_not_valid.title'))
      end
    end

    context 'exception TokenNotPresentError raised' do
      before do
        allow_any_instance_of(ApplicationController).to receive(:verify_token!).and_raise(Exceptions::TokenNotPresentError)
        post "/service/#{service_slug}/user/#{user_identifier}"
      end

      it 'returns a 401 status' do
        expect(response).to have_http_status(401)
      end

      it 'returns json error message' do
        expect(json['errors'].first['title']).to eq(I18n.t('error_messages.token_not_present.title'))
      end
    end

    context 'exception InternalServerError raised' do
      before do
        allow_any_instance_of(ApplicationController).to receive(:verify_token!).and_raise(StandardError)
        post "/service/#{service_slug}/user/#{user_identifier}"
      end
      it 'returns a 500 status' do
        expect(response).to have_http_status(500)
      end

      it 'returns json error message' do
        expect(json['errors'].first['title']).to eq(I18n.t('error_messages.internal_server_error.title'))
      end
    end
  end
end
