# frozen_string_literal: true

RSpec.describe Gate::API::Posts::CreateRequestEntity do
  it_behaves_like "check treaty entity info",
                  attributes: {
                    post: {
                      type: :object,
                      options: {
                        required: { is: true, message: nil }
                      },
                      attributes: {
                        title: {
                          type: :string,
                          options: {
                            required: { is: true, message: nil },
                            transform: { is: Proc, message: nil }
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
                        description: {
                          type: :string,
                          options: {
                            required: { is: false, message: nil }
                          },
                          attributes: {}
                        },
                        content: {
                          type: :string,
                          options: {
                            required: { is: true, message: nil }
                          },
                          attributes: {}
                        },
                        published_at: {
                          type: :string,
                          options: {
                            required: { is: false, message: nil },
                            cast: { to: :datetime, message: nil }
                          },
                          attributes: {}
                        },
                        featured: {
                          type: :string,
                          options: {
                            required: { is: false, message: nil },
                            cast: { to: :boolean, message: nil }
                          },
                          attributes: {}
                        },
                        tags: {
                          type: :array,
                          options: {
                            required: { is: false, message: nil }
                          },
                          attributes: {
                            _self: {
                              type: :string,
                              options: {
                                required: { is: true, message: nil },
                                transform: { is: Proc, message: nil }
                              },
                              attributes: {}
                            }
                          }
                        },
                        author: {
                          type: :object,
                          options: {
                            required: { is: true, message: nil }
                          },
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
                                required: { is: true, message: nil }
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
                                    required: { is: true, message: nil },
                                    as: { is: :value, message: nil }
                                  },
                                  attributes: {}
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
end
