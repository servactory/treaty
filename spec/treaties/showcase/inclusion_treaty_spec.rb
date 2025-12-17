# frozen_string_literal: true

RSpec.describe Showcase::InclusionTreaty do
  subject(:perform) { described_class.call!(inventory:, version:, params:) }

  let(:inventory_collection) { Treaty::Inventory::Collection.new }
  let(:context) { instance_double(ApplicationController) }
  let(:inventory) do
    Treaty::Executor::Inventory.new(inventory_collection, context).tap do |inventory|
      allow(inventory).to receive(:exists?).and_return(inventory_collection.exists?)
    end
  end

  it_behaves_like "check treaty class info",
                  versions: [
                    {
                      version: "1",
                      segments: [1],
                      default: false,
                      summary: "Showing inclusion option with simple mode in request",
                      deprecated: false,
                      executor: {
                        executor: Proc,
                        method: :call
                      },
                      request: {
                        attributes: {
                          showcase: {
                            type: :object,
                            options: {
                              required: { is: true, message: nil }
                            },
                            attributes: {
                              example1: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  inclusion: { in: %w[option1 option2 option3], message: nil }
                                },
                                attributes: {}
                              },
                              example2: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  inclusion: { in: %w[alpha beta gamma], message: nil }
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
                          showcase: {
                            type: :object,
                            options: {
                              required: { is: false, message: nil }
                            },
                            attributes: {
                              example1: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              example2: {
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
                      version: "2",
                      segments: [2],
                      default: false,
                      summary: "Showing inclusion option with advanced mode in request",
                      deprecated: false,
                      executor: {
                        executor: Proc,
                        method: :call
                      },
                      request: {
                        attributes: {
                          showcase: {
                            type: :object,
                            options: {
                              required: { is: true, message: nil }
                            },
                            attributes: {
                              example1: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  inclusion: { in: %w[option1 option2 option3], message: nil }
                                },
                                attributes: {}
                              },
                              example2: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  inclusion: { in: %w[alpha beta gamma], message: nil }
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
                          showcase: {
                            type: :object,
                            options: {
                              required: { is: false, message: nil }
                            },
                            attributes: {
                              example1: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              example2: {
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
                      default: false,
                      summary: "Showing inclusion option in response",
                      deprecated: false,
                      executor: {
                        executor: Proc,
                        method: :call
                      },
                      request: {
                        attributes: {
                          showcase: {
                            type: :object,
                            options: {
                              required: { is: true, message: nil }
                            },
                            attributes: {
                              example1: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              example2: {
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
                          showcase: {
                            type: :object,
                            options: {
                              required: { is: false, message: nil }
                            },
                            attributes: {
                              example1: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  inclusion: { in: %w[option1 option2 option3], message: nil }
                                },
                                attributes: {}
                              },
                              example2: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  inclusion: { in: %w[alpha beta gamma], message: nil }
                                },
                                attributes: {}
                              }
                            }
                          }
                        }
                      }
                    },
                    {
                      version: "4",
                      segments: [4],
                      default: false,
                      summary: "Showing custom message with inclusion option",
                      deprecated: false,
                      executor: {
                        executor: Proc,
                        method: :call
                      },
                      request: {
                        attributes: {
                          showcase: {
                            type: :object,
                            options: {
                              required: { is: true, message: nil }
                            },
                            attributes: {
                              example1: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  inclusion: { in: %w[option1 option2 option3], message: "Invalid option selected" }
                                },
                                attributes: {}
                              },
                              example2: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  inclusion: { in: %w[alpha beta gamma], message: Proc }
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
                          showcase: {
                            type: :object,
                            options: {
                              required: { is: false, message: nil }
                            },
                            attributes: {
                              example1: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              example2: {
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
        {
          showcase: {
            example1: "option1",
            example2: "alpha"
          }
        }
      end

      it { expect { perform }.not_to raise_error }

      it { expect(perform.data).to be_a(Hash) }
      it { expect(perform.status).to eq(200) }
      it { expect(perform.version).to eq(Gem::Version.new("1")) }

      it do
        expect(perform.data).to match(
          {
            showcase: match(
              {
                example1: "option1",
                example2: "alpha"
              }
            )
          }
        )
      end
    end

    context "when version is 2" do
      let(:version) { "2" }

      let(:params) do
        {
          showcase: {
            example1: "option2",
            example2: "beta"
          }
        }
      end

      it { expect { perform }.not_to raise_error }

      it { expect(perform.data).to be_a(Hash) }
      it { expect(perform.status).to eq(200) }
      it { expect(perform.version).to eq(Gem::Version.new("2")) }

      it do
        expect(perform.data).to match(
          {
            showcase: match(
              {
                example1: "option2",
                example2: "beta"
              }
            )
          }
        )
      end
    end

    context "when version is 3" do
      let(:version) { "3" }

      let(:params) do
        {
          showcase: {
            example1: "option3",
            example2: "gamma"
          }
        }
      end

      it { expect { perform }.not_to raise_error }

      it { expect(perform.data).to be_a(Hash) }
      it { expect(perform.status).to eq(200) }
      it { expect(perform.version).to eq(Gem::Version.new("3")) }

      it do
        expect(perform.data).to match(
          {
            showcase: match(
              {
                example1: "option3",
                example2: "gamma"
              }
            )
          }
        )
      end
    end

    context "when version is 4" do
      let(:version) { "4" }

      context "when data is valid" do
        let(:params) do
          {
            showcase: {
              example1: "option1",
              example2: "alpha"
            }
          }
        end

        it { expect { perform }.not_to raise_error }

        it { expect(perform.data).to be_a(Hash) }
        it { expect(perform.status).to eq(200) }
        it { expect(perform.version).to eq(Gem::Version.new("4")) }

        it do
          expect(perform.data).to match(
            {
              showcase: match(
                {
                  example1: "option1",
                  example2: "alpha"
                }
              )
            }
          )
        end
      end

      context "when data is invalid with string message" do
        let(:params) do
          {
            showcase: {
              example1: "invalid",
              example2: "alpha"
            }
          }
        end

        it "raises error with custom string message" do
          expect { perform }.to raise_error(Treaty::Exceptions::Validation) do |error|
            expect(error.message).to include("Invalid option selected")
          end
        end
      end

      context "when data is invalid with lambda message" do
        let(:params) do
          {
            showcase: {
              example1: "option1",
              example2: "invalid"
            }
          }
        end

        it "raises error with custom lambda message" do
          expect { perform }.to raise_error(Treaty::Exceptions::Validation) do |error|
            expect(error.message).to include("example2 must be one of: alpha, beta, gamma")
          end
        end
      end
    end
  end
end
