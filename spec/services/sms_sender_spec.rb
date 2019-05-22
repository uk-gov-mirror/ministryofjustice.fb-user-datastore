require 'rails_helper'

RSpec.describe SmsSender do
  around :each do |example|
    now = Time.new(2019, 1, 1).utc

    Timecop.freeze(now) do
      example.run
    end
  end

  describe '#call' do
    let(:sms_data_object) do
      DataObject::Sms.new(to: 'user@example.com',
                          body: 'body goes here',
                          template_name: 'foo')
    end

    subject do
      described_class.new(sms_data_object: sms_data_object)
    end

    it 'makes correct request' do
      expected_body = '{"service_slug":"datastore","sms":{"template_name":"foo","to":"user@example.com","body":"body goes here"}}'

      expected_headers = {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type'=>'application/json',
        'User-Agent'=>'Ruby',
        'X-Access-Token'=>'eyJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE1NDYzMDA4MDB9.xknzXLc6El1fxdwmm9-r2QvZMINKWG1zrC9nt6b2-5E'
      }

      stub = stub_request(:post, 'http://localhost:3000/sms')
                    .with(headers: expected_headers, body: expected_body)
                    .to_return(status: 201)

      subject.call

      expect(stub).to have_been_requested
    end

    context 'with extra_personalisation' do
      subject do
        described_class.new(sms_data_object: sms_data_object,
                            extra_personalisation: { code: 'foo' })
      end

      it 'makes correct request' do
        expected_body = '{"service_slug":"datastore","sms":{"extra_personalisation":{"code":"foo"},"template_name":"foo","to":"user@example.com","body":"body goes here"}}'

        stub = stub_request(:post, 'http://localhost:3000/sms')
                      .with(body: expected_body)
                      .to_return(status: 201)

        subject.call

        expect(stub).to have_been_requested
      end
    end

    context 'when operation failed server side' do
      before :each do
        stub = stub_request(:post, 'http://localhost:3000/sms').to_return(status: 400)
      end

      it 'raises error' do
        expect { subject.call }.to raise_error(SmsSender::OperationFailed)
      end
    end
  end
end
