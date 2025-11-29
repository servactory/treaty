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
  end
end
