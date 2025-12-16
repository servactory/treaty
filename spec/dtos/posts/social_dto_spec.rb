# frozen_string_literal: true

RSpec.describe Posts::SocialDto do
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
                        required: { is: true, message: nil },
                        as: { is: :value, message: nil }
                      },
                      attributes: {}
                    }
                  }
end
