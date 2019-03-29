require 'rails_helper'

RSpec.describe EmailsController, type: :request do
  let(:headers) do
    {
      'content-type' => 'application/json'
    }
  end

  let(:service_slug) { 'my-service' }

  describe 'POST /service/:service/savereturn/email/add' do
    let(:url) { "/service/#{service_slug}/savereturn/email/add" }

    let(:post_request) do
      post url, params: params.to_json, headers: headers
    end

    before do
      allow_any_instance_of(ApplicationController).to receive(:verify_token!)
    end

    context 'with a valid JSON body' do
      let(:params) do
        {
          email_for_sending: 'jane-doe@example.com',
          email_details: '64c0b8afa7e93d51c1fc5fe82cac4a690927ee1aa5883b985',
          duration: 30,
          link_template: {}
        }
      end

      it 'returns a 201 status' do
        post_request
        expect(response).to have_http_status(201)
      end
    end
  end
end
