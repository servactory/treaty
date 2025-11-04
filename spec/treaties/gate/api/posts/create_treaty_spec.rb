# frozen_string_literal: true

RSpec.describe Gate::API::Posts::CreateTreaty do
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
      Gate::API::PostsController,
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
                      summary: "The first version of the contract for creating a post",
                      deprecated: false,
                      executor: {
                        executor: Posts::V1::CreateService,
                        method: :call
                      },
                      request: {
                        scopes: {
                          post: {
                            attributes: {}
                          }
                        }
                      },
                      response: {
                        status: 201,
                        scopes: {
                          post: {
                            attributes: {}
                          }
                        }
                      }
                    },
                    {
                      version: "2",
                      segments: [2],
                      strategy: :adapter,
                      summary: "Added middle name to expand post data",
                      deprecated: false,
                      executor: {
                        executor: "Posts::Stable::CreateService",
                        method: :call
                      },
                      request: {
                        scopes: {
                          post: {
                            attributes: {
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
                              }
                            }
                          }
                        }
                      },
                      response: {
                        status: 201,
                        scopes: {
                          post: {
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
                      summary: "Added author and socials to expand post data",
                      deprecated: false,
                      executor: {
                        executor: "posts/stable/create_service",
                        method: :call
                      },
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
                          post: {
                            attributes: {
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
                      },
                      response: {
                        status: 201,
                        scopes: {
                          post: {
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
        {
          post: {
            title: "Understanding Kubernetes Pod Networking: A Deep Dive",
            summary:
              "Explore how pods communicate in Kubernetes clusters and learn the fundamentals of CNI plugins, " \
              "network policies, and service mesh integration.",
            description:
              "This comprehensive guide breaks down the complex world of Kubernetes networking, " \
              "explaining how containers within pods share network namespaces and " \
              "how inter-pod communication works across nodes.",
            content: "..."
          }
        }
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
          post: {
            title: "Understanding Kubernetes Pod Networking: A Deep Dive",
            summary:
              "Explore how pods communicate in Kubernetes clusters and learn the fundamentals of CNI plugins, " \
              "network policies, and service mesh integration.",
            description:
              "This comprehensive guide breaks down the complex world of Kubernetes networking, " \
              "explaining how containers within pods share network namespaces and " \
              "how inter-pod communication works across nodes.",
            content: "...",
            author: {
              name: "John Doe",
              bio: "Senior DevOps Engineer specializing in Kubernetes and cloud infrastructure. " \
                   "Speaker and open-source contributor.",
              socials: [
                {
                  provider: "twitter",
                  handle: "johndoe"
                }
              ]
            }
          }
        }
      end

      it { expect { perform }.not_to raise_error }
    end
  end

  context "when required data for work is invalid" do
    context "when version is 2" do
      let(:version) { 2 }

      describe "because request data is incorrect" do
        let(:params) do
          {}
        end

        it :aggregate_failures do
          expect { perform }.to(
            raise_error do |exception|
              expect(exception).to be_a(Treaty::Exceptions::Validation)
              expect(exception.message).to(
                eq("Attribute 'title' is required but was not provided or is empty")
              )
            end
          )
        end
      end
    end

    context "when version is 3" do
      let(:version) { 3 }

      describe "because request data is incorrect" do
        let(:params) do
          {
            # Query
            signature: "...",
            # Body
            post: {
              title: "Understanding Kubernetes Pod Networking: A Deep Dive",
              summary: nil,
              description:
                "This comprehensive guide breaks down the complex world of Kubernetes networking, " \
                "explaining how containers within pods share network namespaces and " \
                "how inter-pod communication works across nodes.",
              content: "...",
              author: {
                name: "John Doe",
                bio: "Senior DevOps Engineer specializing in Kubernetes and cloud infrastructure. " \
                     "Speaker and open-source contributor."
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
                eq("Attribute 'summary' is required but was not provided or is empty")
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
