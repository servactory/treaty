# frozen_string_literal: true

RSpec.describe Gate::API::Posts::IndexTreaty do
  subject(:perform) { described_class.call!(version:, params:) }

  it_behaves_like "check class info",
                  versions: [
                    {
                      version: "1.0.0.rc1",
                      segments: [1, 0, 0, "rc", 1],
                      default: false,
                      strategy: :direct,
                      summary: nil,
                      deprecated: true,
                      executor: {
                        executor: Posts::V1::IndexService,
                        method: :call
                      },
                      request: {
                        scopes: {
                          filters: {
                            attributes: {
                              title: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              summary: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              description: {
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
                          posts: {
                            attributes: {}
                          }
                        }
                      }
                    },
                    {
                      version: "1.0.0.rc2",
                      segments: [1, 0, 0, "rc", 2],
                      default: false,
                      strategy: :direct,
                      summary: nil,
                      deprecated: true,
                      executor: {
                        executor: Posts::V1::IndexService,
                        method: :call
                      },
                      request: {
                        scopes: {
                          filters: {
                            attributes: {
                              title: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              summary: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              description: {
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
                          posts: {
                            attributes: {}
                          }
                        }
                      }
                    },
                    {
                      version: "1",
                      segments: [1],
                      default: false,
                      strategy: :direct,
                      summary: nil,
                      deprecated: false,
                      executor: {
                        executor: Proc,
                        method: :call
                      },
                      request: {
                        scopes: {
                          filters: {
                            attributes: {
                              title: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              summary: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              description: {
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
                          posts: {
                            attributes: {}
                          }
                        }
                      }
                    },
                    {
                      version: "2",
                      segments: [2],
                      default: false,
                      strategy: :adapter,
                      summary: nil,
                      deprecated: false,
                      executor: {
                        executor: Posts::Stable::IndexService,
                        method: :call
                      },
                      request: {
                        scopes: {
                          filters: {
                            attributes: {
                              title: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              summary: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              description: {
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
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              page: {
                                type: :integer,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              limit: {
                                type: :integer,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              }
                            }
                          },
                          posts: {
                            attributes: {
                              id: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              title: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              summary: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
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
                                  required: { is: false, message: nil }
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
                      default: true,
                      strategy: :adapter,
                      summary: nil,
                      deprecated: false,
                      executor: {
                        executor: Posts::Stable::IndexService,
                        method: :call
                      },
                      request: {
                        scopes: {
                          filters: {
                            attributes: {
                              title: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              summary: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              description: {
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
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              page: {
                                type: :integer,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              limit: {
                                type: :integer,
                                options: {
                                  required: { is: false, message: nil },
                                  default: { is: 12, message: nil }
                                },
                                attributes: {}
                              }
                            }
                          },
                          posts: {
                            attributes: {
                              id: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              title: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              summary: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
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
                                  required: { is: false, message: nil }
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
      let(:version) { "1" }

      let(:params) do
        {}
      end

      it { expect { perform }.not_to raise_error }
    end

    context "when version is 2" do
      let(:version) { "2" }

      let(:params) do
        {}
      end

      it { expect { perform }.not_to raise_error }
    end

    context "when version is 3" do
      let(:version) { "3" }

      let(:params) do
        {}
      end

      it { expect { perform }.not_to raise_error }
    end

    describe "when version was not specified" do
      let(:version) { "" }

      let(:params) do
        {}
      end

      it "uses default version 3" do
        expect { perform }.not_to raise_error
      end
    end
  end

  context "when required data for work is invalid" do
    describe "because version is unknown" do
      let(:version) { "999" }

      let(:params) do
        {}
      end

      it :aggregate_failures do
        expect { perform }.to(
          raise_error do |exception|
            expect(exception).to be_a(Treaty::Exceptions::Validation)
            expect(exception.message).to eq("Version 999 not found in treaty definition")
          end
        )
      end
    end
  end
end
