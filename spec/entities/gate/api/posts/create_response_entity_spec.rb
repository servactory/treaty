# frozen_string_literal: true

RSpec.describe Gate::API::Posts::CreateResponseEntity do
  it_behaves_like "check treaty entity info",
                  attributes: {
                    post: {
                      type: :object,
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
                        title: {
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
                        },
                        published_at: {
                          type: :datetime,
                          options: {
                            required: { is: true, message: nil },
                            cast: { to: :string, message: nil }
                          },
                          attributes: {}
                        },
                        featured: {
                          type: :boolean,
                          options: {
                            required: { is: true, message: nil },
                            cast: { to: :integer, message: nil }
                          },
                          attributes: {}
                        },
                        tags: {
                          type: :array,
                          options: {
                            required: { is: true, message: nil }
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
                                required: { is: true, message: nil }
                              },
                              attributes: {
                                provider: {
                                  type: :string,
                                  options: {
                                    required: { is: true, message: nil }
                                  },
                                  attributes: {}
                                },
                                value: {
                                  type: :string,
                                  options: {
                                    required: { is: true, message: nil },
                                    as: { is: :handle, message: nil }
                                  },
                                  attributes: {}
                                }
                              }
                            }
                          }
                        },
                        rating: {
                          type: :integer,
                          options: {
                            required: { is: true, message: nil }
                          },
                          attributes: {}
                        },
                        views: {
                          type: :integer,
                          options: {
                            required: { is: true, message: nil }
                          },
                          attributes: {}
                        },
                        created_at: {
                          type: :time,
                          options: {
                            required: { is: true, message: nil },
                            cast: { to: :integer, message: nil }
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
                      }
                    }
                  }
end
