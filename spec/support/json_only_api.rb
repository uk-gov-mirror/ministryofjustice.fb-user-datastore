RSpec.shared_context 'a JSON-only API' do |method_name, url|
  describe 'a json request' do
    let(:headers) {
      {
        'Content-type' => 'application/json'
      }
    }
    before do
      send(:method_name, url, format: :json, headers: headers)
    end

    it 'responds with the json content type' do
      expect(response.content_type).to eq('application/json')
    end

    it 'does not respond_with :unacceptable' do
      expect(received_response.status).to_not eq(:unacceptable)
    end
  end
end
