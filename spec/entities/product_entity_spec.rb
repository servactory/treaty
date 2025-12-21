# frozen_string_literal: true

RSpec.describe ProductEntity do
  it_behaves_like "check treaty entity info",
                  attributes: {
                    product: {
                      attributes: {
                        id: {
                          type: :string,
                          options: {
                            required: { is: true, message: nil }
                          },
                          attributes: {}
                        },
                        name: {
                          type: :string,
                          options: {
                            required: { is: true, message: nil }
                          },
                          attributes: {}
                        },
                        description: {
                          type: :string,
                          options: {
                            required: { is: false, message: nil }
                          },
                          attributes: {}
                        },
                        price_cents: {
                          type: :integer,
                          options: {
                            required: { is: true, message: nil }
                          },
                          attributes: {}
                        },
                        currency: {
                          type: :string,
                          options: {
                            required: { is: true, message: nil },
                            default: { is: "USD", message: nil }
                          },
                          attributes: {}
                        },
                        status: {
                          type: :string,
                          options: {
                            required: { is: true, message: nil },
                            inclusion: { in: %w[draft active discontinued], message: nil }
                          },
                          attributes: {}
                        },
                        stock_count: {
                          type: :integer,
                          options: {
                            required: { is: true, message: nil },
                            if: { is: Proc, message: nil }
                          },
                          attributes: {}
                        },
                        published_at: {
                          type: :datetime,
                          options: {
                            required: { is: false, message: nil },
                            cast: { to: :string, message: nil },
                            if: { is: Proc, message: nil }
                          },
                          attributes: {}
                        },
                        sku: {
                          type: :string,
                          options: {
                            required: { is: true, message: nil },
                            unless: { is: Proc, message: nil }
                          },
                          attributes: {}
                        },
                        tags: {
                          type: :array,
                          options: {
                            required: { is: false, message: nil },
                            unless: { is: Proc, message: nil }
                          },
                          attributes: {
                            _self: {
                              type: :string,
                              options: {
                                required: { is: true, message: nil }
                              },
                              attributes: {}
                            }
                          }
                        },
                        admin_notes: {
                          type: :string,
                          options: {
                            required: { is: false, message: nil },
                            if: { is: Proc, message: nil }
                          },
                          attributes: {}
                        },
                        discontinued_reason: {
                          type: :string,
                          options: {
                            required: { is: false, message: nil },
                            if: { is: Proc, message: nil }
                          },
                          attributes: {}
                        },
                        manufacturer: {
                          type: :object,
                          options: {
                            required: { is: false, message: nil },
                            unless: { is: Proc, message: nil }
                          },
                          attributes: {
                            name: {
                              type: :string,
                              options: {
                                required: { is: true, message: nil }
                              },
                              attributes: {}
                            },
                            country: {
                              type: :string,
                              options: {
                                required: { is: false, message: nil }
                              },
                              attributes: {}
                            }
                          }
                        },
                        created_at: {
                          type: :time,
                          options: {
                            required: { is: true, message: nil },
                            cast: { to: :string, message: nil }
                          },
                          attributes: {}
                        },
                        updated_at: {
                          type: :time,
                          options: {
                            required: { is: true, message: nil },
                            cast: { to: :string, message: nil }
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