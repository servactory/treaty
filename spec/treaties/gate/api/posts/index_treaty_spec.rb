# frozen_string_literal: true

RSpec.describe Gate::API::Posts::IndexTreaty do
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
                      version: "1.0.0.rc1",
                      segments: [1, 0, 0, "rc", 1],
                      default: false,
                      summary: nil,
                      deprecated: true,
                      executor: {
                        executor: Posts::V1::IndexService,
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
                        attributes: {
                          meta: {
                            type: :object,
                            options: {
                              required: { is: false, message: nil }
                            },
                            attributes: {}
                          },
                          posts: {
                            type: :array,
                            options: {
                              required: { is: false, message: nil }
                            },
                            attributes: {}
                          }
                        }
                      }
                    },
                    {
                      version: "1.0.0.rc2",
                      segments: [1, 0, 0, "rc", 2],
                      default: false,
                      summary: nil,
                      deprecated: true,
                      executor: {
                        executor: Posts::V1::IndexService,
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
                        attributes: {
                          meta: {
                            type: :object,
                            options: {
                              required: { is: false, message: nil }
                            },
                            attributes: {}
                          },
                          posts: {
                            type: :array,
                            options: {
                              required: { is: false, message: nil }
                            },
                            attributes: {}
                          }
                        }
                      }
                    },
                    {
                      version: "1",
                      segments: [1],
                      default: false,
                      summary: nil,
                      deprecated: false,
                      executor: {
                        executor: Proc,
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
                        attributes: {
                          meta: {
                            type: :object,
                            options: {
                              required: { is: false, message: nil }
                            },
                            attributes: {}
                          },
                          posts: {
                            type: :array,
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
                      summary: nil,
                      deprecated: false,
                      executor: {
                        executor: Posts::Stable::IndexService,
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
                        attributes: {
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
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              }
                            }
                          },
                          posts: {
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
                      default: false,
                      summary: nil,
                      deprecated: false,
                      executor: {
                        executor: Posts::Stable::IndexService,
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
                              title: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  transform: { is: Proc, message: nil }
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
                        attributes: {
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
                                  default: { is: 12, message: nil }
                                },
                                attributes: {}
                              }
                            }
                          },
                          posts: {
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
                      version: "4",
                      segments: [4],
                      default: true,
                      summary: nil,
                      deprecated: false,
                      executor: {
                        executor: Posts::Stable::IndexService,
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
                              title: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  transform: { is: Proc, message: nil }
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
                        attributes: {
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
                                  default: { is: 12, message: nil }
                                },
                                attributes: {}
                              }
                            }
                          },
                          posts: {
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
                              },
                              created_at: {
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
                      version: "5",
                      segments: [5],
                      default: false,
                      summary: "Demonstrates type casting functionality",
                      deprecated: false,
                      executor: {
                        executor: Posts::Stable::IndexService,
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
                              title: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  transform: { is: Proc, message: nil }
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
                              published: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  cast: { to: :boolean, message: nil }
                                },
                                attributes: {}
                              },
                              created_after: {
                                type: :integer,
                                options: {
                                  required: { is: false, message: nil },
                                  cast: { to: :datetime, message: nil }
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
                                  default: { is: 12, message: nil }
                                },
                                attributes: {}
                              }
                            }
                          },
                          posts: {
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
                              },
                              created_at: {
                                type: :time,
                                options: {
                                  required: { is: false, message: nil },
                                  cast: { to: :integer, message: nil }
                                },
                                attributes: {}
                              }
                            }
                          }
                        }
                      }
                    },
                    {
                      version: "6",
                      segments: [6],
                      default: false,
                      summary: "Demonstrates date, time, and datetime types with casting",
                      deprecated: false,
                      executor: {
                        executor: Posts::Stable::IndexService,
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
                              title: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  transform: { is: Proc, message: nil }
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
                              published_on: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  cast: { to: :date, message: nil }
                                },
                                attributes: {}
                              },
                              created_at: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  cast: { to: :time, message: nil }
                                },
                                attributes: {}
                              },
                              updated_after: {
                                type: :integer,
                                options: {
                                  required: { is: false, message: nil },
                                  cast: { to: :datetime, message: nil }
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
                                  default: { is: 12, message: nil }
                                },
                                attributes: {}
                              }
                            }
                          },
                          posts: {
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
                              },
                              published_on: {
                                type: :date,
                                options: {
                                  required: { is: false, message: nil },
                                  cast: { to: :string, message: nil }
                                },
                                attributes: {}
                              },
                              created_at: {
                                type: :time,
                                options: {
                                  required: { is: false, message: nil },
                                  cast: { to: :integer, message: nil }
                                },
                                attributes: {}
                              },
                              updated_at: {
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
                    }
                  ]

  context "when required data for work is valid" do
    context "when version is 1" do
      let(:version) { "1" }

      let(:params) do
        {}
      end

      it { expect { perform }.not_to raise_error }

      it { expect(perform.data).to be_a(Hash) }
      it { expect(perform.status).to eq(200) }
      it { expect(perform.version).to eq(Gem::Version.new("1")) }
    end

    context "when version is 2" do
      let(:version) { "2" }

      let(:params) do
        {}
      end

      it { expect { perform }.not_to raise_error }

      it { expect(perform.data).to be_a(Hash) }
      it { expect(perform.status).to eq(200) }
      it { expect(perform.version).to eq(Gem::Version.new("2")) }
    end

    context "when version is 3" do
      let(:version) { "3" }

      let(:params) do
        {}
      end

      it { expect { perform }.not_to raise_error }

      it { expect(perform.data).to be_a(Hash) }
      it { expect(perform.status).to eq(200) }
      it { expect(perform.version).to eq(Gem::Version.new("3")) }
    end

    context "when version is 4" do
      let(:version) { "4" }

      let(:params) do
        {}
      end

      it { expect { perform }.not_to raise_error }

      it { expect(perform.data).to be_a(Hash) }
      it { expect(perform.status).to eq(200) }
      it { expect(perform.version).to eq(Gem::Version.new("4")) }
    end

    context "when version is 5" do
      let(:version) { "5" }

      let(:params) do
        {}
      end

      it { expect { perform }.not_to raise_error }

      it { expect(perform.data).to be_a(Hash) }
      it { expect(perform.status).to eq(200) }
      it { expect(perform.version).to eq(Gem::Version.new("5")) }
    end

    describe "when version was not specified" do
      let(:version) { "" }

      let(:params) do
        {}
      end

      it "uses default version 4" do
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
            expect(exception).to be_a(Treaty::Exceptions::VersionNotFound)
            expect(exception.message).to eq("Version 999 not found in treaty definition")
          end
        )
      end
    end
  end
end
