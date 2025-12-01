# frozen_string_literal: true

RSpec.describe Serialization::OrderDto do
  it_behaves_like "check treaty entity info",
                  attributes: {
                    order: {
                      attributes: {
                        id: {
                          type: :string,
                          options: {
                            required: { is: true, message: nil }
                          },
                          attributes: {}
                        },
                        customer_name: {
                          type: :string,
                          options: {
                            required: { is: true, message: nil }
                          },
                          attributes: {}
                        },
                        items: {
                          type: :array,
                          options: {
                            required: { is: true, message: nil }
                          },
                          attributes: {
                            product_name: {
                              type: :string,
                              options: {
                                required: { is: true, message: nil }
                              },
                              attributes: {}
                            },
                            quantity: {
                              type: :integer,
                              options: {
                                required: { is: true, message: nil }
                              },
                              attributes: {}
                            },
                            unit_price_cents: {
                              type: :integer,
                              options: {
                                required: { is: true, message: nil }
                              },
                              attributes: {}
                            },
                            line_total_cents: {
                              type: :integer,
                              options: {
                                required: { is: true, message: nil },
                                computed: { is: Proc, message: nil }
                              },
                              attributes: {}
                            }
                          }
                        },
                        subtotal_cents: {
                          type: :integer,
                          options: {
                            required: { is: true, message: nil },
                            computed: { is: Proc, message: nil }
                          },
                          attributes: {}
                        },
                        tax_rate_percent: {
                          type: :integer,
                          options: {
                            required: { is: true, message: nil },
                            default: { is: 10, message: nil }
                          },
                          attributes: {}
                        },
                        tax_cents: {
                          type: :integer,
                          options: {
                            required: { is: true, message: nil },
                            computed: { is: Proc, message: nil }
                          },
                          attributes: {}
                        },
                        total_cents: {
                          type: :integer,
                          options: {
                            required: { is: true, message: nil },
                            computed: { is: Proc, message: nil }
                          },
                          attributes: {}
                        },
                        formatted_total: {
                          type: :string,
                          options: {
                            required: { is: true, message: nil },
                            computed: { is: Proc, message: nil }
                          },
                          attributes: {}
                        },
                        created_at: {
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
