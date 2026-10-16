require 'rails_helper'

RSpec.describe 'ConsiderAllRequestsJsonMiddleware' do
  let(:app) { double }

  let(:subject) { ConsiderAllRequestsJsonMiddleware.new(app) }
  let(:env) { {"CONTENT_TYPE"=>"application/x-www-form-urlencoded"} }

  context "when called with a POST request" do
    context "with form encoded header" do
      it "replaces the correct header" do
        expect(app).to receive(:call).with({"CONTENT_TYPE"=>"application/json"})
        subject.call(env)
      end
    end
  end
end