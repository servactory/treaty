# frozen_string_literal: true

RSpec.describe Gate::API::Users::IndexTreaty do
  subject(:perform) { described_class.call!(controller:, params:) }

  let(:request) do
    instance_double(
      ActionDispatch::Request,
      headers:,
      remote_ip: "127.0.0.1",
      user_agent: "Mozilla/5.0"
    )
  end

  let(:controller) do
    instance_double(
      Gate::API::UsersController,
      request:,
      headers:,
      params:
    )
  end

  let(:headers) do
    {
      "Accept" => "application/vnd.myapp-v1+json"
    }
  end

  let(:params) do
    {}
  end

  context "when required data for work is valid" do
    it { expect { perform }.not_to raise_error }
  end
end
