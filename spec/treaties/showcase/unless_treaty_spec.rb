# frozen_string_literal: true

RSpec.describe Showcase::UnlessTreaty do
  subject(:perform) { described_class.call!(inventory:, version:, params:) }

  let(:inventory_collection) { Treaty::Action::Inventory::Collection.new }
  let(:context) { instance_double(ApplicationController) }
  let(:inventory) do
    Treaty::Action::Executor::Inventory.new(inventory_collection, context).tap do |inventory|
      allow(inventory).to receive(:exists?).and_return(inventory_collection.exists?)
    end
  end

  it_behaves_like "check treaty class info",
                  versions: [
                    {
                      version: "1",
                      segments: [1],
                      default: false,
                      summary: "Showing unless option in request",
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
                              flag: {
                                type: :boolean,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
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
                                  required: { is: false, message: nil },
                                  unless: { is: Proc, message: nil }
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
                              flag: {
                                type: :boolean,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
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
                      summary: "Showing unless option in response",
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
                              flag: {
                                type: :boolean,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
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
                              flag: {
                                type: :boolean,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
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
                                  required: { is: false, message: nil },
                                  unless: { is: Proc, message: nil }
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
                      summary: "Showing unless option on nested objects",
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
                              flag: {
                                type: :boolean,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              example1: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              nested: {
                                type: :object,
                                options: {
                                  required: { is: false, message: nil },
                                  unless: { is: Proc, message: nil }
                                },
                                attributes: {
                                  value: {
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
                              flag: {
                                type: :boolean,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              example1: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              nested: {
                                type: :object,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {
                                  value: {
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
                    }
                  ]

  context "when required data for work is valid" do
    context "when version is 1" do
      let(:version) { "1" }

      let(:params) do
        {
          showcase: {
            flag: true,
            example1: "Value 1",
            example2: "Value 2"
          }
        }
      end

      it { expect { perform }.not_to raise_error }

      it { expect(perform.data).to be_a(Hash) }
      it { expect(perform.status).to eq(200) }
      it { expect(perform.version).to eq(Gem::Version.new("1")) }

      it "returns expected values", :aggregate_failures do
        expect(perform.data[:showcase][:flag]).to be(true)
        expect(perform.data[:showcase][:example1]).to eq("Value 1")
      end
    end

    context "when version is 2" do
      let(:version) { "2" }

      let(:params) do
        {
          showcase: {
            flag: true,
            example1: "Value 1",
            example2: "Value 2"
          }
        }
      end

      it { expect { perform }.not_to raise_error }

      it { expect(perform.data).to be_a(Hash) }
      it { expect(perform.status).to eq(200) }
      it { expect(perform.version).to eq(Gem::Version.new("2")) }

      it "returns expected values", :aggregate_failures do
        expect(perform.data[:showcase][:flag]).to be(true)
        expect(perform.data[:showcase][:example1]).to eq("Value 1")
      end
    end

    context "when version is 3" do
      let(:version) { "3" }

      let(:params) do
        {
          showcase: {
            flag: true,
            example1: "Value 1",
            nested: {
              value: "Nested Value"
            }
          }
        }
      end

      it { expect { perform }.not_to raise_error }

      it { expect(perform.data).to be_a(Hash) }
      it { expect(perform.status).to eq(200) }
      it { expect(perform.version).to eq(Gem::Version.new("3")) }

      it "returns expected values", :aggregate_failures do
        expect(perform.data[:showcase][:flag]).to be(true)
        expect(perform.data[:showcase][:example1]).to eq("Value 1")
      end
    end
  end
end
