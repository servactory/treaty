# frozen_string_literal: true

RSpec.describe Serialization::ImageDto do
  it_behaves_like "check treaty entity info",
                  attributes: {
                    image: {
                      attributes: {
                        url: {
                          type: :string,
                          options: {
                            required: { is: true, message: nil }
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
