# frozen_string_literal: true

RSpec.describe Gate::API::Languages::ShowTreaty do
  subject(:perform) { described_class.call!(version:, params:) }

  it_behaves_like "check treaty class info",
                  versions: [
                    {
                      version: "1.0.0",
                      segments: [1, 0, 0],
                      default: false,
                      strategy: :direct,
                      summary: "Show Ruby feature details",
                      deprecated: true,
                      executor: {
                        executor: Languages::V1::ShowService,
                        method: :call
                      },
                      request: {
                        attributes: {
                          id: {
                            type: :string,
                            options: {
                              required: { is: true, message: nil }
                            },
                            attributes: {}
                          }
                        }
                      },
                      response: {
                        status: 200,
                        attributes: {
                          feature: {
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
                      summary: "Added usage examples",
                      deprecated: false,
                      executor: {
                        executor: "Languages::Stable::ShowService",
                        method: :call
                      },
                      request: {
                        attributes: {
                          id: {
                            type: :string,
                            options: {
                              required: { is: true, message: nil }
                            },
                            attributes: {}
                          },
                          include_examples: {
                            type: :boolean,
                            options: {
                              required: { is: false, message: nil }
                            },
                            attributes: {}
                          }
                        }
                      },
                      response: {
                        status: 200,
                        attributes: {
                          feature: {
                            type: :object,
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
                              syntax: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              examples: {
                                type: :array,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {
                                  title: {
                                    type: :string,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  code: {
                                    type: :string,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  explanation: {
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
                      }
                    },
                    {
                      version: "3",
                      segments: [3],
                      default: true,
                      strategy: :adapter,
                      summary: "Added gems and frameworks",
                      deprecated: false,
                      executor: {
                        executor: "languages/stable/show_service",
                        method: :call
                      },
                      request: {
                        attributes: {
                          _self: {
                            type: :object,
                            options: {
                              required: { is: true, message: nil }
                            },
                            attributes: {
                              detailed: {
                                type: :boolean,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              }
                            }
                          },
                          id: {
                            type: :string,
                            options: {
                              required: { is: true, message: nil }
                            },
                            attributes: {}
                          },
                          include_examples: {
                            type: :boolean,
                            options: {
                              required: { is: false, message: nil }
                            },
                            attributes: {}
                          }
                        }
                      },
                      response: {
                        status: 200,
                        attributes: {
                          feature: {
                            type: :object,
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
                              syntax: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              experimental: {
                                type: :boolean,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              examples: {
                                type: :array,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {
                                  title: {
                                    type: :string,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  code: {
                                    type: :string,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  explanation: {
                                    type: :string,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  complexity_level: {
                                    type: :integer,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  }
                                }
                              },
                              ecosystem: {
                                type: :object,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {
                                  gems: {
                                    type: :array,
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
                                      purpose: {
                                        type: :string,
                                        options: {
                                          required: { is: false, message: nil }
                                        },
                                        attributes: {}
                                      },
                                      repository: {
                                        type: :string,
                                        options: {
                                          required: { is: false, message: nil },
                                          as: { is: :repo_url, message: nil }
                                        },
                                        attributes: {}
                                      }
                                    }
                                  },
                                  frameworks: {
                                    type: :array,
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
                                      popular: {
                                        type: :boolean,
                                        options: {
                                          required: { is: false, message: nil }
                                        },
                                        attributes: {}
                                      }
                                    }
                                  },
                                  tools: {
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
                              introduced_at: {
                                type: :datetime,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              updated_at: {
                                type: :datetime,
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
    context "when version is 2" do
      let(:version) { "2" }

      let(:params) do
        {
          id: "feature-456",
          include_examples: true
        }
      end

      it { expect { perform }.not_to raise_error }
    end

    context "when version is 3" do
      let(:version) { "3" }

      let(:params) do
        {
          detailed: true,
          id: "feature-789",
          include_examples: false
        }
      end

      it { expect { perform }.not_to raise_error }
    end

    describe "when version was not specified" do
      let(:version) { "" }

      let(:params) do
        {
          id: "feature-default"
        }
      end

      it "uses default version 3" do
        expect { perform }.not_to raise_error
      end
    end
  end

  context "when required data for work is invalid" do
    context "when version is 1" do
      let(:version) { "1" }

      describe "because id is missing" do
        let(:params) do
          {}
        end

        it :aggregate_failures do
          expect { perform }.to(
            raise_error do |exception|
              expect(exception).to be_a(Treaty::Exceptions::Deprecated)
              expect(exception.message).to(
                eq("Version 1 is deprecated and cannot be used")
              )
            end
          )
        end
      end
    end

    context "when version is 2" do
      let(:version) { "2" }

      describe "because id is missing" do
        let(:params) do
          {
            include_examples: true
          }
        end

        it :aggregate_failures do
          expect { perform }.to(
            raise_error do |exception|
              expect(exception).to be_a(Treaty::Exceptions::Validation)
              expect(exception.message).to(
                eq("Attribute 'id' is required but was not provided or is empty")
              )
            end
          )
        end
      end
    end

    context "when version is 3" do
      let(:version) { "3" }

      describe "because id is missing" do
        let(:params) do
          {
            detailed: false
          }
        end

        it :aggregate_failures do
          expect { perform }.to(
            raise_error do |exception|
              expect(exception).to be_a(Treaty::Exceptions::Validation)
              expect(exception.message).to(
                eq("Attribute 'id' is required but was not provided or is empty")
              )
            end
          )
        end
      end
    end

    describe "because version is unknown" do
      let(:version) { "999" }

      let(:params) do
        {
          id: "feature-999"
        }
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
