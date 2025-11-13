# frozen_string_literal: true

RSpec.describe Serialization::ImageDto do
  it_behaves_like "check treaty entity info",
                  attributes: {
                    image: {
                      attributes: {
                        url: {
                          type: :string,
                          options: {
                            required: { is: true, message: "Image URL is mandatory" }
                          },
                          attributes: {}
                        },
                        alt: {
                          type: :string,
                          options: {
                            required: { is: false, message: nil }
                          },
                          attributes: {}
                        },
                        format: {
                          type: :string,
                          options: {
                            required: { is: true, message: "Format must be specified" },
                            inclusion: { in: %w[jpg png gif webp], message: nil }
                          },
                          attributes: {}
                        },
                        size: {
                          type: :string,
                          options: {
                            required: { is: true, message: nil },
                            inclusion: {
                              in: %w[small medium large],
                              message: Proc
                            },
                            default: { is: "medium", message: nil }
                          },
                          attributes: {}
                        },
                        width: {
                          type: :integer,
                          options: {
                            required: { is: false, message: nil }
                          },
                          attributes: {}
                        },
                        height: {
                          type: :integer,
                          options: {
                            required: { is: false, message: nil }
                          },
                          attributes: {}
                        }
                      },
                      options: {
                        required: { is: true, message: nil }
                      },
                      type: :object
                    }
                  }
end
