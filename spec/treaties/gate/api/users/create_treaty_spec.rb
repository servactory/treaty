# frozen_string_literal: true

RSpec.describe Gate::API::Users::CreateTreaty do
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
                      version: "1",
                      segments: [1],
                      strategy: :direct,
                      summary: "The first version of the contract for creating a user",
                      deprecated: false,
                      executor: Users::V1::CreateService,
                      request: {
                        scopes: {
                          user: {}
                        }
                      },
                      response: {
                        status: 201,
                        scopes: {
                          user: {}
                        }
                      }
                    },
                    {
                      version: "2",
                      segments: [2],
                      strategy: :adapter,
                      summary: "Added middle name to expand user data",
                      deprecated: false,
                      executor: Users::Stable::CreateService,
                      request: {
                        scopes: {
                          user: {}
                        }
                      },
                      response: {
                        status: 201,
                        scopes: {
                          user: {}
                        }
                      }
                    },
                    {
                      version: "3",
                      segments: [3],
                      strategy: :adapter,
                      summary: "Added address and socials to expand user data",
                      deprecated: false,
                      executor: Users::Stable::CreateService,
                      request: {
                        scopes: {
                          self: {},
                          user: {}
                        }
                      },
                      response: {
                        status: 201,
                        scopes: {
                          user: {}
                        }
                      }
                    }
                  ]

  context "when required data for work is valid" do
    it { expect { perform }.not_to raise_error }
  end
end
