# frozen_string_literal: true

RSpec.describe Shared::SocialEntity do
  it_behaves_like "check treaty entity info",
                  attributes: {
                    provider: {
                      type: :string,
                      options: {
                        required: { is: true, message: nil },
                        inclusion: { in: %w[twitter linkedin github], message: nil }
                      },
                      attributes: {}
                    },
                    handle: {
                      type: :string,
                      options: {
                        required: { is: true, message: nil }
                      },
                      attributes: {}
                    }
                  }
end