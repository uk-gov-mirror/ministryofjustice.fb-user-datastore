require 'rails_helper'

RSpec.describe SaveAndReturn::ProgressSavedEmailSender do
  around :each do |example|
    now = Time.new(2019, 1, 1).utc

    Timecop.freeze(now) do
      example.run
    end
  end

  describe '#call' do
    let(:email_data_object) do
      DataObject::Email.new(to: 'user@example.com',
                            subject: 'subject goes here',
                            body: 'body goes here',
                            template_name: 'foo')
    end

    subject do
      described_class.new(email_data_object: email_data_object)
    end

    it 'makes correct request' do
      expected_body = '{"service_slug":"datastore","email":{"template_name":"foo","to":"user@example.com","subject":"subject goes here","body":"body goes here"}}'

      expected_headers = {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type'=>'application/json',
        'User-Agent'=>'Ruby',
        'X-Access-Token'=>'eyJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE1NDYzMDA4MDB9.xknzXLc6El1fxdwmm9-r2QvZMINKWG1zrC9nt6b2-5E'
      }

      stub = stub_request(:post, 'http://localhost:3000/save_return/email_progress_saved')
                    .with(headers: expected_headers, body: expected_body)
                    .to_return(status: 201)

      subject.call

      expect(stub).to have_been_requested
    end

    context 'when operation failed server side' do
      before :each do
        stub = stub_request(:post, 'http://localhost:3000/save_return/email_progress_saved')
                          .to_return(status: 400)
      end

      it 'raises error' do
        expect { subject.call }.to raise_error(SaveAndReturn::ProgressSavedEmailSender::OperationFailed)
      end
    end
  end
end
