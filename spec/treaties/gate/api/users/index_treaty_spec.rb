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
      "Accept" => "application/vnd.myapp-v3+json"
    }
  end

  let(:params) do
    {}
  end

  it_behaves_like "check class info",
                  versions: [
                    {
                      version: "1.0.0.rc1",
                      segments: [1, 0, 0, "rc", 1],
                      strategy: :direct,
                      summary: nil,
                      deprecated: true,
                      executor: Users::V1::IndexService
                    },
                    {
                      version: "1.0.0.rc2",
                      segments: [1, 0, 0, "rc", 2],
                      strategy: :direct,
                      summary: nil,
                      deprecated: true,
                      executor: Users::V1::IndexService
                    },
                    {
                      version: "1",
                      segments: [1],
                      strategy: :direct,
                      summary: nil,
                      deprecated: false,
                      executor: Users::V1::IndexService
                    },
                    {
                      version: "2",
                      segments: [2],
                      strategy: :adapter,
                      summary: nil,
                      deprecated: false,
                      executor: Users::Stable::IndexService
                    }
                  ]

  context "when required data for work is valid" do
    it { expect { perform }.not_to raise_error }
  end
end
