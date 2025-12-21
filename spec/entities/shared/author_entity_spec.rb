# frozen_string_literal: true

RSpec.describe Shared::AuthorEntity do
  it_behaves_like "check treaty entity info",
                  attributes: {
                    name: {
                      type: :string,
                      options: {
                        required: { is: true, message: nil }
                      },
                      attributes: {}
                    },
                    bio: {
                      type: :string,
                      options: {
                        required: { is: false, message: nil }
                      },
                      attributes: {}
                    },
                    socials: {
                      type: :array,
                      options: {
                        required: { is: false, message: nil }
                      },
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
                    }
                  }
end
