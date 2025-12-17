# frozen_string_literal: true

RSpec.describe Showcase::CastTreaty do
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
                      summary: "Showing cast option with string to datetime in request",
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
                                  cast: { to: :datetime, message: nil }
                                },
                                attributes: {}
                              },
                              example2: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  cast: { to: :date, message: nil }
                                },
                                attributes: {}
                              },
                              example3: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  cast: { to: :time, message: nil }
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
                                type: :datetime,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              example2: {
                                type: :date,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              example3: {
                                type: :time,
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
                      summary: "Showing cast option with datetime to string in response",
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
                                type: :datetime,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              example2: {
                                type: :date,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              example3: {
                                type: :time,
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
                                type: :datetime,
                                options: {
                                  required: { is: false, message: nil },
                                  cast: { to: :string, message: nil }
                                },
                                attributes: {}
                              },
                              example2: {
                                type: :date,
                                options: {
                                  required: { is: false, message: nil },
                                  cast: { to: :string, message: nil }
                                },
                                attributes: {}
                              },
                              example3: {
                                type: :time,
                                options: {
                                  required: { is: false, message: nil },
                                  cast: { to: :string, message: nil }
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
                      summary: "Showing cast option with integer conversions",
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
                                type: :integer,
                                options: {
                                  required: { is: false, message: nil },
                                  cast: { to: :boolean, message: nil }
                                },
                                attributes: {}
                              },
                              example2: {
                                type: :integer,
                                options: {
                                  required: { is: false, message: nil },
                                  cast: { to: :string, message: nil }
                                },
                                attributes: {}
                              },
                              example3: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  cast: { to: :integer, message: nil }
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
                                type: :boolean,
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
                      version: "4",
                      segments: [4],
                      default: false,
                      summary: "Showing cast option with advanced mode in request",
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
                                  cast: { to: :datetime, message: nil }
                                },
                                attributes: {}
                              },
                              example2: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  cast: { to: :integer, message: nil }
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
                                type: :datetime,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              example2: {
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
                    }
                  ]

  context "when required data for work is valid" do
    context "when version is 1" do
      let(:version) { "1" }

      let(:params) do
        {
          showcase: {
            example1: "2024-01-15T10:30:00Z",
            example2: "2024-01-15",
            example3: "10:30:00"
          }
        }
      end

      it { expect { perform }.not_to raise_error }

      it { expect(perform.data).to be_a(Hash) }
      it { expect(perform.status).to eq(200) }
      it { expect(perform.version).to eq(Gem::Version.new("1")) }

      it do
        expect(perform.data[:showcase][:example1]).to be_a(DateTime)
        expect(perform.data[:showcase][:example2]).to be_a(Date)
        expect(perform.data[:showcase][:example3]).to be_a(Time)
      end
    end

    context "when version is 2" do
      let(:version) { "2" }

      let(:params) do
        {
          showcase: {
            example1: DateTime.new(2024, 1, 15, 10, 30, 0),
            example2: Date.new(2024, 1, 15),
            example3: Time.new(2024, 1, 15, 10, 30, 0)
          }
        }
      end

      it { expect { perform }.not_to raise_error }

      it { expect(perform.data).to be_a(Hash) }
      it { expect(perform.status).to eq(200) }
      it { expect(perform.version).to eq(Gem::Version.new("2")) }

      it do
        expect(perform.data[:showcase][:example1]).to be_a(String)
        expect(perform.data[:showcase][:example2]).to be_a(String)
        expect(perform.data[:showcase][:example3]).to be_a(String)
      end
    end

    context "when version is 3" do
      let(:version) { "3" }

      let(:params) do
        {
          showcase: {
            example1: 1,
            example2: 42,
            example3: "123"
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
                example1: true,
                example2: "42",
                example3: 123
              }
            )
          }
        )
      end
    end

    context "when version is 4" do
      let(:version) { "4" }

      let(:params) do
        {
          showcase: {
            example1: "2024-01-15T10:30:00Z",
            example2: "42"
          }
        }
      end

      it { expect { perform }.not_to raise_error }

      it { expect(perform.data).to be_a(Hash) }
      it { expect(perform.status).to eq(200) }
      it { expect(perform.version).to eq(Gem::Version.new("4")) }

      it do
        expect(perform.data[:showcase][:example1]).to be_a(DateTime)
        expect(perform.data[:showcase][:example2]).to eq(42)
      end
    end
  end
end
