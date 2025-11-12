# frozen_string_literal: true

RSpec.describe Gate::API::Languages::IndexTreaty do
  subject(:perform) { described_class.call!(version:, params:) }

  it_behaves_like "check treaty class info",
                  versions: [
                    {
                      version: "1",
                      segments: [1],
                      default: false,
                      strategy: :direct,
                      summary: "List Ruby language features",
                      deprecated: false,
                      executor: {
                        executor: Languages::V1::IndexService,
                        method: :call
                      },
                      request: {
                        attributes: {
                          filters: {
                            type: :object,
                            options: {
                              required: { is: false, message: nil }
                            },
                            attributes: {
                              name: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              category: {
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
                        attributes: {
                          features: {
                            type: :array,
                            options: {
                              required: { is: false, message: nil }
                            },
                            attributes: {}
                          },
                          meta: {
                            type: :object,
                            options: {
                              required: { is: false, message: nil }
                            },
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
                      summary: "Added version filter and gems",
                      deprecated: false,
                      executor: {
                        executor: Languages::Stable::IndexService,
                        method: :call
                      },
                      request: {
                        attributes: {
                          filters: {
                            type: :object,
                            options: {
                              required: { is: false, message: nil }
                            },
                            attributes: {
                              name: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              category: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              version: {
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
                        attributes: {
                          features: {
                            type: :array,
                            options: {
                              required: { is: false, message: nil }
                            },
                            attributes: {
                              id: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              name: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              category: {
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
                              gems: {
                                type: :array,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {
                                  _self: {
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
                          meta: {
                            type: :object,
                            options: {
                              required: { is: false, message: nil }
                            },
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
                      summary: "Added paradigm and statistics",
                      deprecated: false,
                      executor: {
                        executor: "languages/stable/index_service",
                        method: :call
                      },
                      request: {
                        attributes: {
                          filters: {
                            type: :object,
                            options: {
                              required: { is: false, message: nil }
                            },
                            attributes: {
                              name: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              category: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              version: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              paradigm: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  inclusion: { in: %w[functional imperative object-oriented], message: nil }
                                },
                                attributes: {}
                              }
                            }
                          }
                        }
                      },
                      response: {
                        status: 200,
                        attributes: {
                          features: {
                            type: :array,
                            options: {
                              required: { is: false, message: nil }
                            },
                            attributes: {
                              id: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              name: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              category: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              paradigm: {
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
                              gems: {
                                type: :array,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {
                                  _self: {
                                    type: :string,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  }
                                }
                              },
                              statistics: {
                                type: :object,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {
                                  usage_count: {
                                    type: :integer,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  popularity_score: {
                                    type: :integer,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  }
                                }
                              },
                              introduced_at: {
                                type: :datetime,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              }
                            }
                          },
                          meta: {
                            type: :object,
                            options: {
                              required: { is: false, message: nil }
                            },
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
                                  default: { is: 20, message: nil }
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
        {
          filters: {
            name: "Blocks",
            category: "syntax"
          }
        }
      end

      it { expect { perform }.not_to raise_error }
    end

    context "when version is 3" do
      let(:version) { "3" }

      let(:params) do
        {
          filters: {
            name: "Lambdas",
            paradigm: "functional"
          }
        }
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
    context "when version is 3" do
      let(:version) { "3" }

      describe "because paradigm value is not in allowed list" do
        let(:params) do
          {
            filters: {
              paradigm: "invalid-paradigm"
            }
          }
        end

        it :aggregate_failures do
          expect { perform }.to(
            raise_error do |exception|
              expect(exception).to be_a(Treaty::Exceptions::Validation)
              expect(exception.message).to(
                eq(
                  "Attribute 'paradigm' must be one of: " \
                  "functional, imperative, object-oriented. Got: 'invalid-paradigm'"
                )
              )
            end
          )
        end
      end
    end

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
