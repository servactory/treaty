# frozen_string_literal: true

RSpec.describe Showcase::DefaultTreaty do
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
                      summary: "Showing default value in request",
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
                                  default: { is: "Example 1", message: nil }
                                },
                                attributes: {}
                              },
                              example2: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  default: { is: "Example 2", message: nil }
                                },
                                attributes: {}
                              },
                              example3: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  default: { is: Proc, message: nil }
                                },
                                attributes: {}
                              },
                              example4: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  default: { is: Proc, message: nil }
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
                              },
                              example3: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              example4: {
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
                      summary: "Showing default value in response",
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
                              },
                              example3: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              example4: {
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
                                  default: { is: "Example 1", message: nil }
                                },
                                attributes: {}
                              },
                              example2: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  default: { is: "Example 2", message: nil }
                                },
                                attributes: {}
                              },
                              example3: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  default: { is: Proc, message: nil }
                                },
                                attributes: {}
                              },
                              example4: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  default: { is: Proc, message: nil }
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
                      summary: "Showing custom message with required option",
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
                                  required: { is: true, message: "Example1 is required" }
                                },
                                attributes: {}
                              },
                              example2: {
                                type: :string,
                                options: {
                                  required: { is: true, message: Proc }
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
            example1: nil,
            example2: nil,
            example3: nil,
            example4: nil
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
                example1: "Example 1",
                example2: "Example 2",
                example3: "Example 3",
                example4: "Example 4"
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
            example1: nil,
            example2: nil,
            example3: nil,
            example4: nil
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
                example1: "Example 1",
                example2: "Example 2",
                example3: "Example 3",
                example4: "Example 4"
              }
            )
          }
        )
      end
    end

    context "when version is 3" do
      let(:version) { "3" }

      context "when data is valid" do
        let(:params) do
          {
            showcase: {
              example1: "Value 1",
              example2: "Value 2"
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
                  example1: "Value 1",
                  example2: "Value 2"
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
              example1: nil,
              example2: "Value 2"
            }
          }
        end

        it "raises error with custom string message", :aggregate_failures do
          expect { perform }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to include("Example1 is required")
            end
          )
        end
      end

      context "when data is invalid with lambda message" do
        let(:params) do
          {
            showcase: {
              example1: "Value 1",
              example2: nil
            }
          }
        end

        it "raises error with custom lambda message", :aggregate_failures do
          expect { perform }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to include("example2 cannot be blank")
            end
          )
        end
      end
    end
  end
end
