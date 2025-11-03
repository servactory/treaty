# frozen_string_literal: true

RSpec.describe Gate::API::Users::CreateTreaty do
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
      "Accept" => "application/vnd.myapp-v#{version}+json"
    }
  end

  it_behaves_like "check class info",
                  versions: [
                    {
                      version: "1",
                      segments: [1],
                      strategy: :direct,
                      summary: "The first version of the contract for creating a user",
                      deprecated: false,
                      executor: Users::V1::CreateService,
                      request: {
                        scopes: {
                          user: {
                            attributes: {}
                          }
                        }
                      },
                      response: {
                        status: 201,
                        scopes: {
                          user: {
                            attributes: {}
                          }
                        }
                      }
                    },
                    {
                      version: "2",
                      segments: [2],
                      strategy: :adapter,
                      summary: "Added middle name to expand user data",
                      deprecated: false,
                      executor: Users::Stable::CreateService,
                      request: {
                        scopes: {
                          user: {
                            attributes: {
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
                                  required: { is: false, message: nil }
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
                      },
                      response: {
                        status: 201,
                        scopes: {
                          user: {
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
                    },
                    {
                      version: "3",
                      segments: [3],
                      strategy: :adapter,
                      summary: "Added address and socials to expand user data",
                      deprecated: false,
                      executor: Users::Stable::CreateService,
                      request: {
                        scopes: {
                          self: {
                            attributes: {
                              signature: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil }
                                },
                                attributes: {}
                              }
                            }
                          },
                          user: {
                            attributes: {
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
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              last_name: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil }
                                },
                                attributes: {}
                              },
                              address: {
                                type: :object,
                                options: {
                                  required: { is: true, message: nil }
                                },
                                attributes: {
                                  street: {
                                    type: :string,
                                    options: {
                                      required: { is: true, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  city: {
                                    type: :string,
                                    options: {
                                      required: { is: true, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  state: {
                                    type: :string,
                                    options: {
                                      required: { is: true, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  zipcode: {
                                    type: :string,
                                    options: {
                                      required: { is: true, message: nil }
                                    },
                                    attributes: {}
                                  }
                                }
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
                      },
                      response: {
                        status: 201,
                        scopes: {
                          user: {
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
                              },
                              address: {
                                type: :object,
                                options: {
                                  required: { is: true, message: nil }
                                },
                                attributes: {
                                  street: {
                                    type: :string,
                                    options: {
                                      required: { is: true, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  city: {
                                    type: :string,
                                    options: {
                                      required: { is: true, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  state: {
                                    type: :string,
                                    options: {
                                      required: { is: true, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  zipcode: {
                                    type: :string,
                                    options: {
                                      required: { is: true, message: nil }
                                    },
                                    attributes: {}
                                  }
                                }
                              },
                              created_at: {
                                type: :datetime,
                                options: {
                                  required: { is: true, message: nil }
                                },
                                attributes: {}
                              },
                              updated_at: {
                                type: :datetime,
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
    context "when version is 1" do
      let(:version) { 1 }

      let(:params) do
        {}
      end

      it { expect { perform }.not_to raise_error }
    end

    context "when version is 2" do
      let(:version) { 2 }

      let(:params) do
        {}
      end

      it { expect { perform }.not_to raise_error }
    end

    context "when version is 3" do
      let(:version) { 3 }

      let(:params) do
        {
          # Query
          signature: "...",
          # Body
          user: {
            first_name: "John",
            middle_name: nil,
            last_name: "Doe",
            address: {
              street: "123 Main St",
              city: "Anytown",
              state: "NY",
              zipcode: "12345"
            },
            socials: [
              {
                provider: "twitter",
                handle: "johndoe"
              }
            ]
          }
        }
      end

      it { expect { perform }.not_to raise_error }
    end
  end

  context "when required data for work is invalid" do
    context "when version is 3" do
      let(:version) { 3 }

      describe "because request data is incorrect" do
        let(:params) do
          {
            # Query
            signature: "...",
            # Body
            user: {
              first_name: "John",
              middle_name: nil,
              last_name: nil,
              address: {
                street: "123 Main St",
                city: "Anytown",
                state: "NY",
                zipcode: "12345"
              },
              socials: [
                {
                  provider: "twitter",
                  handle: "johndoe"
                }
              ]
            }
          }
        end

        it :aggregate_failures do
          expect { perform }.to(
            raise_error do |exception|
              expect(exception).to be_a(Treaty::Exceptions::Validation)
              expect(exception.message).to(
                eq("Attribute 'last_name' is required but was not provided or is empty")
              )
            end
          )
        end
      end
    end

    describe "because version is unknown" do
      let(:version) { 999 }

      let(:params) do
        {}
      end

      it :aggregate_failures do
        expect { perform }.to(
          raise_error do |exception|
            expect(exception).to be_a(Treaty::Exceptions::Validation)
            expect(exception.message).to(
              eq("Version 999 not found in treaty definition")
            )
          end
        )
      end
    end
  end
end
