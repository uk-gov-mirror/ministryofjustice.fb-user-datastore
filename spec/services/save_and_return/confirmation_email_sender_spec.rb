require 'rails_helper'

RSpec.describe SaveAndReturn::ConfirmationEmailSender do
  around :each do |example|
    now = Time.new(2019, 1, 1).utc

    Timecop.freeze(now) do
      example.run
    end
  end

  describe '#call' do
    subject do
      described_class.new(email: 'user@example.com',
                          confirmation_link: 'https://example.com/foo',
                          template_context: {
                            a: true,
                            b: 1,
                            c: 'foo'
                          })
    end

    it 'makes correct request' do
      expected_body = '{"service_slug":"datastore","email":"user@example.com","confirmation_link":"https://example.com/foo","template_context":{"a":true,"b":1,"c":"foo"}}'

      expected_headers = {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby', 'X-Access-Token'=>'eyJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE1NDYzMDA4MDB9.xknzXLc6El1fxdwmm9-r2QvZMINKWG1zrC9nt6b2-5E' }

      stub = stub_request(:post, 'http://localhost:3000/save_return/email_confirmations')
              .with(headers: expected_headers, body: expected_body)

      subject.call

      expect(stub).to have_been_requested
    end
  end
end
