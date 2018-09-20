RSpec.shared_context 'a JWT-authenticated method' do |method, url, payload|
  let(:body) { response.body }
  let(:parsed_body) {
    JSON.parse(response.body)
  }
  let(:headers) {
    {
      'content-type' => 'application/json'
    }
  }
  before do
    send(method, url, headers: headers)
  end

  context 'with no x-access-token header' do
    it 'has status 401' do
      expect(response).to have_http_status(401)
    end

    describe 'the body' do
      let(:body){ response.body }

      it 'is valid JSON' do
        expect { parsed_body }.to_not raise_error
      end

      describe 'the error key' do
        it 'has a message indicating the header is not present' do
          expect(parsed_body.fetch('error')).to eq(
            I18n.t(:header_not_present, scope: [:common, :errors])
          )
        end
      end
    end

  end
  context 'with a header called x-access-token' do
    before do
      headers['x-access-token'] = token
    end

    context 'which is valid' do
      let(:token) { 'valid_token' }
    end

    context 'which is not valid' do
      let(:token) { 'invalid token' }

      context 'as the timestamp is older than MAX_IAT_SKEW_SECONDS' do
        let(:iat) { Time.current - (env['MAX_IAT_SKEW_SECONDS'] + 1) }

        it 'has status 403' do
          expect(response).to have_http_status(403)
        end

        describe 'the body' do
          it 'is valid JSON' do
            expect { parsed_body }.to_not raise_error
          end

          describe 'the error key' do
            it 'has a message indicating the token is invalid' do
              expect(parsed_body.fetch('error')).to eq(
                I18n.t(:token_not_valid, scope: [:common, :errors])
              )
            end
          end
        end
      end

      context 'as the timestamp is > MAX_IAT_SKEW_SECONDS seconds in the future' do
        let(:iat) { Time.current + (env['MAX_IAT_SKEW_SECONDS'] + 1) }

        it 'has status 403' do
          expect(response.status).to eq(403)
        end

        describe 'the body' do
          it 'is valid JSON' do
            expect { parsed_body }.to_not raise_error
          end

          describe 'the error key' do
            it 'has a message indicating the token is invalid' do
              expect(parsed_body.fetch('error')).to eq(
                I18n.t(:token_not_valid, scope: [:common, :errors])
              )
            end
          end
        end
      end
    end
  end

end
