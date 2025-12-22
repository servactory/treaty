# frozen_string_literal: true

RSpec.describe Showcase::AsTreaty do
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
                      summary: "Showing as option in request",
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
                              user_name: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  as: { is: :name, message: nil }
                                },
                                attributes: {}
                              },
                              user_email: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  as: { is: :email, message: nil }
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
                              name: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              email: {
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
                      summary: "Showing as option in response",
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
                              name: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              email: {
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
                              name: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  as: { is: :user_name, message: nil }
                                },
                                attributes: {}
                              },
                              email: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  as: { is: :user_email, message: nil }
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
            user_name: "John Doe",
            user_email: "john@example.com"
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
                name: "John Doe",
                email: "john@example.com"
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
            name: "Jane Smith",
            email: "jane@example.com"
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
                user_name: "Jane Smith",
                user_email: "jane@example.com"
              }
            )
          }
        )
      end
    end
  end
end
