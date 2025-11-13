# frozen_string_literal: true

RSpec.describe Gate::API::Movies::ShowTreaty do
  subject(:perform) { described_class.call!(version:, params:) }

  it_behaves_like "check treaty class info",
                  versions: [
                    {
                      version: "1",
                      segments: [1],
                      default: false,
                      strategy: :direct,
                      summary: "Show movie details",
                      deprecated: false,
                      executor: {
                        executor: Movies::V1::ShowService,
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
                          movie: {
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
                              year: {
                                type: :integer,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              genre: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              runtime: {
                                type: :integer,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              plot: {
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
                      strategy: :adapter,
                      summary: "Added cast and memorable scenes",
                      deprecated: false,
                      executor: {
                        executor: "Movies::Stable::ShowService",
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
                          include_cast: {
                            type: :boolean,
                            options: {
                              required: { is: false, message: nil }
                            },
                            attributes: {}
                          },
                          include_scenes: {
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
                          movie: {
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
                              year: {
                                type: :integer,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              genre: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              runtime: {
                                type: :integer,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              plot: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              rating: {
                                type: :integer,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              cast: {
                                type: :array,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {
                                  actor: {
                                    type: :string,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  character: {
                                    type: :string,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  role_type: {
                                    type: :string,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  lead_role: {
                                    type: :boolean,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  }
                                }
                              },
                              scenes: {
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
                                  location: {
                                    type: :string,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  duration: {
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
                      }
                    },
                    {
                      version: "3",
                      segments: [3],
                      default: true,
                      strategy: :adapter,
                      summary: "Added soundtrack and trivia",
                      deprecated: false,
                      executor: {
                        executor: "movies/stable/show_service",
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
                              api_key: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil }
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
                          include_cast: {
                            type: :boolean,
                            options: {
                              required: { is: false, message: nil }
                            },
                            attributes: {}
                          },
                          include_scenes: {
                            type: :boolean,
                            options: {
                              required: { is: false, message: nil }
                            },
                            attributes: {}
                          },
                          include_soundtrack: {
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
                          movie: {
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
                              year: {
                                type: :integer,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              genre: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              runtime: {
                                type: :integer,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              plot: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              rating: {
                                type: :integer,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              cult_classic: {
                                type: :boolean,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              contains_violence: {
                                type: :boolean,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              cast: {
                                type: :array,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {
                                  actor: {
                                    type: :string,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  character: {
                                    type: :string,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  role_type: {
                                    type: :string,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  lead_role: {
                                    type: :boolean,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  screen_time: {
                                    type: :integer,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  }
                                }
                              },
                              scenes: {
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
                                  location: {
                                    type: :string,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  duration: {
                                    type: :integer,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  iconic: {
                                    type: :boolean,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  }
                                }
                              },
                              soundtrack: {
                                type: :object,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {
                                  tracks: {
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
                                      artist: {
                                        type: :string,
                                        options: {
                                          required: { is: false, message: nil }
                                        },
                                        attributes: {}
                                      },
                                      album: {
                                        type: :string,
                                        options: {
                                          required: { is: false, message: nil },
                                          as: { is: :source, message: nil }
                                        },
                                        attributes: {}
                                      },
                                      year: {
                                        type: :integer,
                                        options: {
                                          required: { is: false, message: nil }
                                        },
                                        attributes: {}
                                      }
                                    }
                                  }
                                }
                              },
                              awards: {
                                type: :object,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {
                                  oscars: {
                                    type: :integer,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  golden_globes: {
                                    type: :integer,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  cannes_awards: {
                                    type: :integer,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  }
                                }
                              },
                              trivia: {
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
                              production: {
                                type: :object,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {
                                  studio: {
                                    type: :string,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  director: {
                                    type: :string,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  budget: {
                                    type: :integer,
                                    options: {
                                      required: { is: false, message: nil }
                                    },
                                    attributes: {}
                                  },
                                  box_office: {
                                    type: :integer,
                                    options: {
                                      required: { is: false, message: nil },
                                      as: { is: :revenue, message: nil }
                                    },
                                    attributes: {}
                                  }
                                }
                              },
                              released_at: {
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
    context "when version is 1" do
      let(:version) { "1" }

      let(:params) do
        {
          id: "movie-123"
        }
      end

      it { expect { perform }.not_to raise_error }
    end

    context "when version is 2" do
      let(:version) { "2" }

      let(:params) do
        {
          id: "movie-456",
          include_cast: true,
          include_scenes: true
        }
      end

      it { expect { perform }.not_to raise_error }
    end

    context "when version is 3" do
      let(:version) { "3" }

      let(:params) do
        {
          api_key: "secret-key-123",
          id: "movie-789",
          include_cast: false,
          include_scenes: true,
          include_soundtrack: true
        }
      end

      it { expect { perform }.not_to raise_error }
    end

    describe "when version was not specified" do
      let(:version) { "" }

      let(:params) do
        {
          api_key: "default-key",
          id: "movie-default"
        }
      end

      it "uses default version 3" do
        expect { perform }.not_to raise_error
      end
    end
  end

  context "when required data for work is invalid" do
    context "when version is 2" do
      let(:version) { "2" }

      describe "because id is missing" do
        let(:params) do
          {}
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

      describe "because api_key is missing" do
        let(:params) do
          {
            id: "movie-999"
          }
        end

        it :aggregate_failures do
          expect { perform }.to(
            raise_error do |exception|
              expect(exception).to be_a(Treaty::Exceptions::Validation)
              expect(exception.message).to(
                eq("Attribute 'api_key' is required but was not provided or is empty")
              )
            end
          )
        end
      end

      describe "because id is missing" do
        let(:params) do
          {
            api_key: "test-key"
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
          id: "movie-999"
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
