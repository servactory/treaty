# frozen_string_literal: true

RSpec.describe Gate::API::Posts::CreateTreaty do
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
                      summary: "The first version of the contract for creating a post",
                      deprecated: false,
                      executor: {
                        executor: Posts::V1::CreateService,
                        method: :call
                      },
                      request: {
                        attributes: {
                          post: {
                            type: :object,
                            options: {
                              required: { is: true, message: nil }
                            },
                            attributes: {}
                          }
                        }
                      },
                      response: {
                        status: 201,
                        attributes: {
                          post: {
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
                      summary: "Added middle name to expand post data",
                      deprecated: false,
                      executor: {
                        executor: "Posts::Stable::CreateService",
                        method: :call
                      },
                      request: {
                        attributes: {
                          post: {
                            type: :object,
                            options: {
                              required: { is: false, message: nil }
                            },
                            attributes: {
                              title: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil }
                                },
                                attributes: {}
                              },
                              summary: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil }
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
                                  required: { is: true, message: nil }
                                },
                                attributes: {}
                              }
                            }
                          }
                        }
                      },
                      response: {
                        status: 201,
                        attributes: {
                          post: {
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
                      summary: "Added author and socials to expand post data",
                      deprecated: false,
                      executor: {
                        executor: "posts/stable/create_service",
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
                              signature: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil }
                                },
                                attributes: {}
                              }
                            }
                          },
                          post: {
                            type: :object,
                            options: {
                              required: { is: true, message: nil }
                            },
                            attributes: {
                              title: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil },
                                  transform: { is: Proc, message: nil }
                                },
                                attributes: {}
                              },
                              summary: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil }
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
                                  required: { is: true, message: nil }
                                },
                                attributes: {}
                              },
                              published: {
                                type: :boolean,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              tags: {
                                type: :array,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {
                                  _self: {
                                    type: :string,
                                    options: {
                                      required: { is: true, message: nil },
                                      transform: { is: Proc, message: nil }
                                    },
                                    attributes: {}
                                  }
                                }
                              },
                              author: {
                                type: :object,
                                options: {
                                  required: { is: true, message: nil }
                                },
                                attributes: {
                                  name: {
                                    type: :string,
                                    options: {
                                      required: { is: true, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  bio: {
                                    type: :string,
                                    options: {
                                      required: { is: true, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  socials: {
                                    type: :array,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {
                                      provider: {
                                        type: :string,
                                        options: {
                                          required: { is: true, message: nil },
                                          inclusion: { in: %w[twitter linkedin github], message: nil }
                                        },
                                        attributes: {}
                                      },
                                      handle: {
                                        type: :string,
                                        options: {
                                          required: { is: true, message: nil },
                                          as: { is: :value, message: nil }
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
                      },
                      response: {
                        status: 201,
                        attributes: {
                          post: {
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
                              published: {
                                type: :boolean,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              featured: {
                                type: :boolean,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              tags: {
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
                              author: {
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
                                  bio: {
                                    type: :string,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  socials: {
                                    type: :array,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {
                                      provider: {
                                        type: :string,
                                        options: {
                                          required: { is: false, message: nil }
                                        },
                                        attributes: {}
                                      },
                                      value: {
                                        type: :string,
                                        options: {
                                          required: { is: false, message: nil },
                                          as: { is: :handle, message: nil }
                                        },
                                        attributes: {}
                                      }
                                    }
                                  }
                                }
                              },
                              rating: {
                                type: :integer,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              views: {
                                type: :integer,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              created_at: {
                                type: :time,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              updated_at: {
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
                      version: "4",
                      segments: [4],
                      default: false,
                      summary: "Demonstrates type casting functionality",
                      deprecated: false,
                      executor: {
                        executor: "posts/stable/create_service",
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
                              signature: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil }
                                },
                                attributes: {}
                              }
                            }
                          },
                          post: {
                            type: :object,
                            options: {
                              required: { is: true, message: nil }
                            },
                            attributes: {
                              title: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil },
                                  transform: { is: Proc, message: nil }
                                },
                                attributes: {}
                              },
                              summary: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil }
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
                                  required: { is: true, message: nil }
                                },
                                attributes: {}
                              },
                              published: {
                                type: :boolean,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              published_at: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  cast: { to: :datetime, message: nil }
                                },
                                attributes: {}
                              },
                              tags: {
                                type: :array,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {
                                  _self: {
                                    type: :string,
                                    options: {
                                      required: { is: true, message: nil },
                                      transform: { is: Proc, message: nil }
                                    },
                                    attributes: {}
                                  }
                                }
                              },
                              author: {
                                type: :object,
                                options: {
                                  required: { is: true, message: nil }
                                },
                                attributes: {
                                  name: {
                                    type: :string,
                                    options: {
                                      required: { is: true, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  bio: {
                                    type: :string,
                                    options: {
                                      required: { is: true, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  socials: {
                                    type: :array,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {
                                      provider: {
                                        type: :string,
                                        options: {
                                          required: { is: true, message: nil },
                                          inclusion: { in: %w[twitter linkedin github], message: nil }
                                        },
                                        attributes: {}
                                      },
                                      handle: {
                                        type: :string,
                                        options: {
                                          required: { is: true, message: nil },
                                          as: { is: :value, message: nil }
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
                      },
                      response: {
                        status: 201,
                        attributes: {
                          post: {
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
                              published: {
                                type: :boolean,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              featured: {
                                type: :boolean,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              published_at: {
                                type: :time,
                                options: {
                                  required: { is: false, message: nil },
                                  cast: { to: :string, message: nil }
                                },
                                attributes: {}
                              },
                              tags: {
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
                              author: {
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
                                  bio: {
                                    type: :string,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  socials: {
                                    type: :array,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {
                                      provider: {
                                        type: :string,
                                        options: {
                                          required: { is: false, message: nil }
                                        },
                                        attributes: {}
                                      },
                                      value: {
                                        type: :string,
                                        options: {
                                          required: { is: false, message: nil },
                                          as: { is: :handle, message: nil }
                                        },
                                        attributes: {}
                                      }
                                    }
                                  }
                                }
                              },
                              rating: {
                                type: :integer,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              views: {
                                type: :integer,
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
        {
          post: {
            title: "Title 1",
            summary: "Summary 1"
          }
        }
      end

      it { expect { perform }.not_to raise_error }
    end

    context "when version is 2" do
      let(:version) { "2" }

      let(:params) do
        {
          post: {
            title: "Title 1",
            summary: "Summary 1",
            description: "Description 1",
            content: "..."
          }
        }
      end

      it { expect { perform }.not_to raise_error }
    end

    context "when version is 3" do
      let(:version) { "3" }

      let(:params) do
        {
          # Query
          signature: "...",
          # Body
          post: {
            title: "Title 1",
            summary: "Summary 1",
            description: "Description 1",
            content: "...",
            published: true,
            tags: %w[tag1 tag2 tag3],
            author: {
              name: "John Doe",
              bio: "...",
              socials: [
                {
                  provider: "twitter",
                  handle: "johndoe"
                }
              ]
            }
          }
        }
      end

      it { expect { perform }.not_to raise_error }

      context "with transform option applied" do
        let(:params) do
          {
            signature: "...",
            post: {
              title: "  Title With Spaces  ",
              summary: "Summary 1",
              description: "Description 1",
              content: "...",
              tags: %w[TAG1 TAG2 TAG3],
              author: {
                name: "John Doe",
                bio: "...",
                socials: [
                  {
                    provider: "twitter",
                    handle: "johndoe"
                  }
                ]
              }
            }
          }
        end

        it "transforms title by stripping spaces and tags to lowercase", :aggregate_failures do
          result = perform

          # The transformed value (stripped title) should be passed to the service
          expect(result.data[:post][:title]).to eq("Title With Spaces")
          expect(result.data[:post][:tags]).to eq(%w[tag1 tag2 tag3])
        end
      end
    end
  end

  context "when required data for work is invalid" do
    context "when version is 2" do
      let(:version) { "2" }

      describe "because request data is incorrect" do
        let(:params) do
          {
            post: {}
          }
        end

        it :aggregate_failures do
          expect { perform }.to(
            raise_error do |exception|
              expect(exception).to be_a(Treaty::Exceptions::Validation)
              expect(exception.message).to(
                eq("Attribute 'title' is required but was not provided or is empty")
              )
            end
          )
        end
      end
    end

    context "when version is 3" do
      let(:version) { "3" }

      describe "because required attribute is missing" do
        let(:params) do
          {
            # Query
            signature: "...",
            # Body
            post: {
              title: "Title 1",
              summary: nil, # problem with this attribute
              description: "Description 1",
              content: "...",
              tags: %w[tag1 tag2 tag3],
              author: {
                name: "John Doe",
                bio: "..."
              },
              socials: [
                {
                  provider: "twitter",
                  handle: "johndoe"
                }
              ]
            }
          }
        end

        it :aggregate_failures do
          expect { perform }.to(
            raise_error do |exception|
              expect(exception).to be_a(Treaty::Exceptions::Validation)
              expect(exception.message).to(
                eq("Attribute 'summary' is required but was not provided or is empty")
              )
            end
          )
        end
      end

      describe "because there is invalid value in tag attribute" do
        let(:params) do
          {
            # Query
            signature: "...",
            # Body
            post: {
              title: "Title 1",
              summary: "Summary 1",
              description: "Description 1",
              content: "...",
              tags: ["tag1", "tag2", "tag3", 4],
              author: {
                name: "John Doe",
                bio: "...",
                socials: [
                  {
                    provider: "twitter",
                    handle: "johndoe"
                  }
                ]
              }
            }
          }
        end

        it :aggregate_failures do
          expect { perform }.to(
            raise_error do |exception|
              expect(exception).to be_a(Treaty::Exceptions::Validation)
              expect(exception.message).to(
                eq(
                  "Error in array 'tags' at index 3: Element must match one of the defined types. " \
                  "Errors: Attribute '_self' must be a String, got Integer"
                )
              )
            end
          )
        end
      end
    end

    context "when version is 4" do
      let(:version) { "4" }

      describe "because required attribute is missing" do
        let(:params) do
          {
            # Query
            signature: "...",
            # Body
            post: {
              title: "Title 1",
              summary: nil, # problem with this attribute
              description: "Description 1",
              content: "...",
              tags: %w[tag1 tag2 tag3],
              author: {
                name: "John Doe",
                bio: "..."
              },
              socials: [
                {
                  provider: "twitter",
                  handle: "johndoe"
                }
              ]
            }
          }
        end

        it :aggregate_failures do
          expect { perform }.to(
            raise_error do |exception|
              expect(exception).to be_a(Treaty::Exceptions::Validation)
              expect(exception.message).to(
                eq("Attribute 'summary' is required but was not provided or is empty")
              )
            end
          )
        end
      end

      describe "because there is invalid value in tag attribute" do
        let(:params) do
          {
            # Query
            signature: "...",
            # Body
            post: {
              title: "Title 1",
              summary: "Summary 1",
              description: "Description 1",
              content: "...",
              tags: ["tag1", "tag2", "tag3", 4],
              author: {
                name: "John Doe",
                bio: "...",
                socials: [
                  {
                    provider: "twitter",
                    handle: "johndoe"
                  }
                ]
              }
            }
          }
        end

        it :aggregate_failures do
          expect { perform }.to(
            raise_error do |exception|
              expect(exception).to be_a(Treaty::Exceptions::Validation)
              expect(exception.message).to(
                eq(
                  "Error in array 'tags' at index 3: Element must match one of the defined types. " \
                  "Errors: Attribute '_self' must be a String, got Integer"
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
            expect(exception).to be_a(Treaty::Exceptions::VersionNotFound)
            expect(exception.message).to(
              eq("Version 999 not found in treaty definition")
            )
          end
        )
      end
    end

    describe "because version was not specified" do
      let(:version) { "" }

      let(:params) do
        {}
      end

      it :aggregate_failures do
        expect { perform }.to(
          raise_error do |exception|
            expect(exception).to be_a(Treaty::Exceptions::SpecifiedVersionNotFound)
            expect(exception.message).to eq("Specified version is required for validation")
          end
        )
      end
    end
  end
end
