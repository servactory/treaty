# frozen_string_literal: true

RSpec.describe Serialization::Gate::API::Posts::IndexDto do
  it_behaves_like "check treaty entity info",
                  attributes: {
                    posts: {
                      type: :array,
                      options: {
                        required: { is: true, message: nil }
                      },
                      attributes: {
                        id: {
                          type: :string,
                          options: {
                            required: { is: true, message: nil }
                          },
                          attributes: {}
                        },
                        summary: {
                          type: :string,
                          options: {
                            required: { is: true, message: nil }
                          },
                          attributes: {}
                        },
                        title: {
                          type: :string,
                          options: {
                            required: { is: true, message: nil }
                          },
                          attributes: {}
                        },
                        description: {
                          type: :string,
                          options: {
                            required: { is: true, message: nil }
                          },
                          attributes: {}
                        },
                        content: {
                          type: :string,
                          options: {
                            required: { is: true, message: nil }
                          },
                          attributes: {}
                        }
                      }
                    },
                    meta: {
                      type: :object,
                      options: {
                        required: { is: true, message: nil }
                      },
                      attributes: {
                        count: {
                          type: :integer,
                          options: {
                            required: { is: true, message: nil }
                          },
                          attributes: {}
                        },
                        page: {
                          type: :integer,
                          options: {
                            required: { is: true, message: nil }
                          },
                          attributes: {}
                        },
                        limit: {
                          type: :integer,
                          options: {
                            required: { is: true, message: nil },
                            default: { is: 12, message: nil }
                          },
                          attributes: {}
                        }
                      }
                    }
                  }
end
