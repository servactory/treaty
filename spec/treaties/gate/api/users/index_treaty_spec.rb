# frozen_string_literal: true

RSpec.describe Gate::API::Users::IndexTreaty do
  subject(:perform) { described_class.call!(controller:, params:) }

  let(:request) do
    instance_double(
      ActionDispatch::Request,
      headers:,
      remote_ip: "127.0.0.1",
      user_agent: "Mozilla/5.0"
    )
  end

  let(:controller) do
    instance_double(
      Gate::API::UsersController,
      request:,
      headers:,
      params:
    )
  end

  let(:headers) do
    {
      "Accept" => "application/vnd.myapp-v3+json"
    }
  end

  let(:params) do
    {}
  end

  it_behaves_like "check class info",
                  versions: [
                    {
                      version: "1.0.0.rc1",
                      segments: [1, 0, 0, "rc", 1],
                      strategy: :direct,
                      summary: nil,
                      deprecated: true,
                      executor: Users::V1::IndexService,
                      request: {
                        scopes: {
                          filters: {
                            attributes: {
                              first_name: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              middle_name: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              last_name: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              }
                            }
                          }
                        }
                      },
                      response: {
                        status: 200,
                        scopes: {
                          meta: {
                            attributes: {}
                          },
                          users: {
                            attributes: {}
                          }
                        }
                      }
                    },
                    {
                      version: "1.0.0.rc2",
                      segments: [1, 0, 0, "rc", 2],
                      strategy: :direct,
                      summary: nil,
                      deprecated: true,
                      executor: Users::V1::IndexService,
                      request: {
                        scopes: {
                          filters: {
                            attributes: {
                              first_name: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              middle_name: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              last_name: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              }
                            }
                          }
                        }
                      },
                      response: {
                        status: 200,
                        scopes: {
                          meta: {
                            attributes: {}
                          },
                          users: {
                            attributes: {}
                          }
                        }
                      }
                    },
                    {
                      version: "1",
                      segments: [1],
                      strategy: :direct,
                      summary: nil,
                      deprecated: false,
                      executor: Users::V1::IndexService,
                      request: {
                        scopes: {
                          filters: {
                            attributes: {
                              first_name: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              middle_name: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              last_name: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              }
                            }
                          }
                        }
                      },
                      response: {
                        status: 200,
                        scopes: {
                          meta: {
                            attributes: {}
                          },
                          users: {
                            attributes: {}
                          }
                        }
                      }
                    },
                    {
                      version: "2",
                      segments: [2],
                      strategy: :adapter,
                      summary: nil,
                      deprecated: false,
                      executor: Users::Stable::IndexService,
                      request: {
                        scopes: {
                          filters: {
                            attributes: {
                              first_name: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              middle_name: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              last_name: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              }
                            }
                          }
                        }
                      },
                      response: {
                        status: 200,
                        scopes: {
                          meta: {
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
                                  required: { is: true, message: nil }
                                },
                                attributes: {}
                              }
                            }
                          },
                          users: {
                            attributes: {
                              id: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil }
                                },
                                attributes: {}
                              },
                              first_name: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil }
                                },
                                attributes: {}
                              },
                              middle_name: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil }
                                },
                                attributes: {}
                              },
                              last_name: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil }
                                },
                                attributes: {}
                              }
                            }
                          }
                        }
                      }
                    }
                  ]

  context "when required data for work is valid" do
    it { expect { perform }.not_to raise_error }
  end
end
