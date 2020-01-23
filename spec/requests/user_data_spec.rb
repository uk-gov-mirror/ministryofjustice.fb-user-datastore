require 'rails_helper'

RSpec.describe 'UserData API', type: :request do
  let(:headers) {
    {
      'content-type' => 'application/json',
      'x-access-token-v2' => jwt
    }
  }
  let(:service_slug) { 'my-service' }
  let(:user_identifier) { SecureRandom::uuid }
  let(:jwt) { JWT.encode({sub: user_identifier, iat: Time.current.to_i}, private_key, 'RS256') }
  let(:encoded_private_key) { 'LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBM1NUQjJMZ2gwMllrdCtMcXo5bjY5MlNwV0xFdXNUR1hEMGlmWTBuRHpmbXF4MWVlCmx6MXh4cEpPTGV0ckxncW4zN2hNak5ZMC9uQUNjTWR1RUg5S1hycmFieFhYVGwxeVkyMStnbVd4NDlOZVlESW4KYmRtKzZzNUt2TGdVTk43WFZjZVA5UHVxWnlzeENWQTRUbm1MRURLZ2xTV2JVeWZ0QmVhVENKVkk2NFoxMmRNdApQYkFneFdBZmVTTGxiN0JQbHNIbS9IMEFBTCtuYmFPQ2t3dnJQSkRMVFZPek9XSE1vR2dzMnJ4akJIRC9OV05aCnNUVlFhbzRYd2hlYnVkaGx2TWlrRVczMldLZ0t1SEhXOHpkdlU4TWozM1RYK1picVhPaWtkRE54dHd2a1hGN0wKQTNZaDhMSTVHeWQ5cDZmMjdNZmxkZ1VJSFN4Y0pweTFKOEFQcXdJREFRQUJBb0lCQUU5ZjJTQVRmemlraWZ0aQp2RXRjZnlMN0EzbXRKd2c4dDI2cDcyT3czMUg0RWg4NHlOaWFHbE5ld2lialAvWW5wdmU2NitjRkg4SlBxK0NWCkJHRnhmdDBmampXZkRrZTNiTTVaUjdaQUVDaW8vay9pMEpveU5MK015ZkNRMWRmZ1FFUXV1L0gvdnJzSEdyT3cKRW5YQVZIUzg1enlCWWczbjM4QmxjVkw4V2s4R3FlMGxCUU5RSks5dSt5ckc5NEpoUTVoMTZubXlyQ0xpWkhSTAoyWS94MTdDL3BCN1VlUVFWeDZ4aVZSdVdmT1FoWlNmT2IzRHpsYldhc2owa2pTaHdWWDFQVG5sU0lxQXo5T3krClY5M013VFBtbVNOOGFiL0pGVlVBUzhtckM2elcxc0NjcFVUTFZHRVZBUFBJcWpjMmZFKzdLVGNjVDFzWkt0MWIKb2p1R2xSa0NnWUVBL2ZuK3VZcCtxSzdiQmxkUTZCSmNsNXpkR0xybXRrWFFZR096d2cvN21zd0NVdUM3UFpGYQpJV0xBSGM4QU85eDZvUFQ0SzFPNnQzYVBtMW8vUTR1S1N2NWNGK3EwaThMemVQM2JxdnowQXBXekdPVFdiMXg5CnNBRzNIOCtIT3JNS0NXVWl3bm5pUG1PMDNXUUY0dmFoWUd1WXYzSkNSNTYxanBJOFRkMkx6QmNDZ1lFQTN1ZkwKKzdqNGE2elVBOUNrak5wSnB2VkxyQk8ydUpiRHk5NXBpSzlCU3FIellQSEw3VVBWTExFaXRGWlNBWlRWRzFHMwpWbUNxMVoraXhCcTRST0t2VldyME1mSklsUlEvQXBQY3NwVXJjRTRPcnAxRkEyNjlLdXhhdnI5dmpLMCtIbWNRClEydWNRWWdUeWFXQlNZeW9laW04QWQ2UlpJRzVLQ25uTVlhNThZMENnWUVBNUp6VG5VLzlFdm5TVGJMck1QclcKUGVNRlllMWJIMWRZYW10VXM2cVBZSmVpdjlkcXM5RFN3SnFUTkVIUWhCSENrSC94bzQ2SzAvbjA2bkloNERzTApFTlpGTDRJbFltanBvRTlpSEZmMWpSNFRTS1UwSUttd3VXM1IyT0NGYVdFZjk3VUJ4T3pScWpjMTV0TFNPYXFuCk9KT2h1ekt1VnFtVjQrL2VPSGprRGFFQ2dZQUdMVFloeTRaV3RYdEtmOFdQZ1p6NDIyTTFhWFp1dHY3Rjcydk4KTmM0QlcydDdERGd5WXViTlRqcy85QVJodHRZUTQ3ckkwZlRwNW5xRUpKbG1qMEY4aEhJdjBCN2l3cVRjVld5UQpKa0lGNHFQVmd0WWV1anJUcmFqMkVDZnZKZjNLcWVCeGZkSGVudjZ0WDhDdFlSQnFFaTM3ZjBkWUdhQWYxTWxyClBlaDVJUUtCZ1FDbmN6YU8xcUx3VktyeUc4TzF5ZUhDSjQzT1h6SENwN3VnOE90aS9ScmhWZ08wSCtEdVpXUzUKSWhydHpUeU56MExyQTdibVFLTWZ4Y3k5Y29LOG9zZnVma1pZenJxM1ZFa0ViUCtjRWdLcGtlTDlaY2RSbXZ3WQozSTZkMUlOWVUwMldPSzhiRUJBNElJNGc0ak9ZcjJJUjFzb2lWZ0E2YnVya3E3QnMrUm41WFE9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=' }
  let(:private_key) { OpenSSL::PKey::RSA.new(Base64.strict_decode64(encoded_private_key)) }
  let(:encoded_public_key) { 'LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUEzU1RCMkxnaDAyWWt0K0xxejluNgo5MlNwV0xFdXNUR1hEMGlmWTBuRHpmbXF4MWVlbHoxeHhwSk9MZXRyTGdxbjM3aE1qTlkwL25BQ2NNZHVFSDlLClhycmFieFhYVGwxeVkyMStnbVd4NDlOZVlESW5iZG0rNnM1S3ZMZ1VOTjdYVmNlUDlQdXFaeXN4Q1ZBNFRubUwKRURLZ2xTV2JVeWZ0QmVhVENKVkk2NFoxMmRNdFBiQWd4V0FmZVNMbGI3QlBsc0htL0gwQUFMK25iYU9Da3d2cgpQSkRMVFZPek9XSE1vR2dzMnJ4akJIRC9OV05ac1RWUWFvNFh3aGVidWRobHZNaWtFVzMyV0tnS3VISFc4emR2ClU4TWozM1RYK1picVhPaWtkRE54dHd2a1hGN0xBM1loOExJNUd5ZDlwNmYyN01mbGRnVUlIU3hjSnB5MUo4QVAKcXdJREFRQUIKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg==' }
  let(:public_key) { OpenSSL::PKey::RSA.new(Base64.strict_decode64(encoded_public_key)) }
  let(:fake_service) { double(:service) }

  before do
    allow(ServiceTokenService).to receive(:new).with(service_slug: service_slug).and_return(fake_service)
    allow(fake_service).to receive(:public_key).and_return(public_key)
  end

  describe 'a GET request' do
    context 'to /service/:service_slug/user/:user_identifier' do
      let(:url) { "/service/#{service_slug}/user/#{user_identifier}" }

      context 'with a valid token' do
        before do
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
              expect(response.media_type).to eq("application/json")
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

      context 'with a valid token' do
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

            it 'is valid JSON' do
              post_request
              expect { json }.to_not raise_error
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

            it 'responds with :ok status' do
              post_request
              expect(response).to have_http_status(:ok)
            end

            it 'is valid JSON' do
              post_request
              expect { json }.to_not raise_error
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
