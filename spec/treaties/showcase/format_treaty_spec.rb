# frozen_string_literal: true

RSpec.describe Showcase::FormatTreaty do
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
                      summary: "Showing format option with basic formats in request",
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
                                  format: { is: :uuid, message: nil }
                                },
                                attributes: {}
                              },
                              example2: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :email, message: nil }
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
                      summary: "Showing format option with date/time formats in request",
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
                                  format: { is: :date, message: nil }
                                },
                                attributes: {}
                              },
                              example2: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :datetime, message: nil }
                                },
                                attributes: {}
                              },
                              example3: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :time, message: nil }
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
                      summary: "Showing format option with other formats in request",
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
                                  format: { is: :password, message: nil }
                                },
                                attributes: {}
                              },
                              example2: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :duration, message: nil }
                                },
                                attributes: {}
                              },
                              example3: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :boolean, message: nil }
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
                      summary: "Showing format option with advanced mode in request",
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
                                  format: { is: :uuid, message: nil }
                                },
                                attributes: {}
                              },
                              example2: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :email, message: nil }
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
                      version: "5",
                      segments: [5],
                      default: false,
                      summary: "Showing custom message with format option",
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
                                  format: { is: :email, message: "Invalid email format" }
                                },
                                attributes: {}
                              },
                              example2: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :uuid, message: Proc }
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
            example1: "550e8400-e29b-41d4-a716-446655440000",
            example2: "test@example.com"
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
                example1: "550e8400-e29b-41d4-a716-446655440000",
                example2: "test@example.com"
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
            example1: "2024-01-15",
            example2: "2024-01-15T10:30:00Z",
            example3: "10:30:00"
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
                example1: "2024-01-15",
                example2: "2024-01-15T10:30:00Z",
                example3: "10:30:00"
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
            example1: "Password1A",
            example2: "P1D",
            example3: "true"
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
                example1: "Password1A",
                example2: "P1D",
                example3: "true"
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
            example1: "550e8400-e29b-41d4-a716-446655440000",
            example2: "test@example.com"
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
                example1: "550e8400-e29b-41d4-a716-446655440000",
                example2: "test@example.com"
              }
            )
          }
        )
      end
    end

    context "when version is 5" do
      let(:version) { "5" }

      context "when data is valid" do
        let(:params) do
          {
            showcase: {
              example1: "test@example.com",
              example2: "550e8400-e29b-41d4-a716-446655440000"
            }
          }
        end

        it { expect { perform }.not_to raise_error }

        it { expect(perform.data).to be_a(Hash) }
        it { expect(perform.status).to eq(200) }
        it { expect(perform.version).to eq(Gem::Version.new("5")) }

        it do
          expect(perform.data).to match(
            {
              showcase: match(
                {
                  example1: "test@example.com",
                  example2: "550e8400-e29b-41d4-a716-446655440000"
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
              example1: "invalid-email",
              example2: "550e8400-e29b-41d4-a716-446655440000"
            }
          }
        end

        it "raises error with custom string message", :aggregate_failures do
          expect { perform }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to include("Invalid email format")
            end
          )
        end
      end

      context "when data is invalid with lambda message" do
        let(:params) do
          {
            showcase: {
              example1: "test@example.com",
              example2: "invalid-uuid"
            }
          }
        end

        it "raises error with custom lambda message", :aggregate_failures do
          expect { perform }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to include("example2 is not a valid UUID")
            end
          )
        end
      end
    end
  end
end
