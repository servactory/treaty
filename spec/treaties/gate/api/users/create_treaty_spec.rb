# frozen_string_literal: true

RSpec.describe Gate::API::Users::CreateTreaty do
  subject(:perform) { described_class.call!(version:, params:) }

  it_behaves_like "check treaty class info",
                  versions: [
                    {
                      version: "1",
                      segments: [1],
                      default: false,
                      strategy: :adapter,
                      summary: "User creation with format validation examples",
                      deprecated: false,
                      executor: {
                        executor: "Users::CreateService",
                        method: :call
                      },
                      request: {
                        attributes: {
                          user: {
                            type: :object,
                            options: {
                              required: { is: true, message: nil }
                            },
                            attributes: {
                              email: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil },
                                  format: { is: :email, message: nil }
                                },
                                attributes: {}
                              },
                              username: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil }
                                },
                                attributes: {}
                              },
                              password: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil },
                                  format: {
                                    is: :password,
                                    message: "Password must be 8-16 characters with at least one digit, " \
                                             "lowercase, and uppercase letter"
                                  }
                                },
                                attributes: {}
                              },
                              recovery_email: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :email, message: "Recovery email must be valid" }
                                },
                                attributes: {}
                              },
                              birth_date: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :date, message: nil }
                                },
                                attributes: {}
                              },
                              preferred_notification_time: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :time, message: nil }
                                },
                                attributes: {}
                              },
                              email_verified: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :boolean, message: nil }
                                },
                                attributes: {}
                              },
                              external_id: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :uuid, message: nil }
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
                          user: {
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
                              email: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :email, message: nil }
                                },
                                attributes: {}
                              },
                              username: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil }
                                },
                                attributes: {}
                              },
                              recovery_email: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :email, message: nil }
                                },
                                attributes: {}
                              },
                              birth_date: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :date, message: nil }
                                },
                                attributes: {}
                              },
                              preferred_notification_time: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :time, message: nil }
                                },
                                attributes: {}
                              },
                              email_verified: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :boolean, message: nil }
                                },
                                attributes: {}
                              },
                              external_id: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :uuid, message: nil }
                                },
                                attributes: {}
                              },
                              created_at: {
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
                    },
                    {
                      version: "2",
                      segments: [2],
                      default: false,
                      strategy: :adapter,
                      summary: "Extended user creation with Entity-based definition",
                      deprecated: false,
                      executor: {
                        executor: "Users::CreateService",
                        method: :call
                      },
                      request: {
                        attributes: {
                          user: {
                            type: :object,
                            options: {
                              required: { is: true, message: nil }
                            },
                            attributes: {
                              email: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil },
                                  format: { is: :email, message: nil }
                                },
                                attributes: {}
                              },
                              username: {
                                type: :string,
                                options: {
                                  required: { is: true, message: "Username is required" }
                                },
                                attributes: {}
                              },
                              recovery_email: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :email, message: "Recovery email must be a valid email address" }
                                },
                                attributes: {}
                              },
                              password: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil },
                                  format: { is: :password, message: Proc }
                                },
                                attributes: {}
                              },
                              role: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil },
                                  inclusion: { in: %w[admin user guest], message: nil },
                                  default: { is: "user", message: nil }
                                },
                                attributes: {}
                              },
                              last_login_at: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :datetime, message: nil }
                                },
                                attributes: {}
                              },
                              birth_date: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :date, message: nil }
                                },
                                attributes: {}
                              },
                              preferred_notification_time: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :time, message: nil }
                                },
                                attributes: {}
                              },
                              email_verified: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :boolean, message: nil }
                                },
                                attributes: {}
                              },
                              session_duration: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :duration, message: nil }
                                },
                                attributes: {}
                              },
                              external_id: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :uuid, message: nil }
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
                          user: {
                            type: :object,
                            options: {
                              required: { is: true, message: nil }
                            },
                            attributes: {
                              id: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil }
                                },
                                attributes: {}
                              },
                              email: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil },
                                  format: { is: :email, message: nil }
                                },
                                attributes: {}
                              },
                              username: {
                                type: :string,
                                options: {
                                  required: { is: true, message: "Username is required" }
                                },
                                attributes: {}
                              },
                              recovery_email: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :email, message: "Recovery email must be a valid email address" }
                                },
                                attributes: {}
                              },
                              password: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil },
                                  format: { is: :password, message: Proc }
                                },
                                attributes: {}
                              },
                              role: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil },
                                  inclusion: { in: %w[admin user guest], message: nil },
                                  default: { is: "user", message: nil }
                                },
                                attributes: {}
                              },
                              last_login_at: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :datetime, message: nil }
                                },
                                attributes: {}
                              },
                              birth_date: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :date, message: nil }
                                },
                                attributes: {}
                              },
                              preferred_notification_time: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :time, message: nil }
                                },
                                attributes: {}
                              },
                              email_verified: {
                                type: :string,
                                options: {
                                  required: { is: true, message: nil },
                                  format: { is: :boolean, message: nil },
                                  default: { is: "false", message: nil }
                                },
                                attributes: {}
                              },
                              session_duration: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :duration, message: nil }
                                },
                                attributes: {}
                              },
                              external_id: {
                                type: :string,
                                options: {
                                  required: { is: false, message: nil },
                                  format: { is: :uuid, message: nil }
                                },
                                attributes: {}
                              },
                              created_at: {
                                type: :datetime,
                                options: {
                                  required: { is: true, message: nil }
                                },
                                attributes: {}
                              },
                              updated_at: {
                                type: :datetime,
                                options: {
                                  required: { is: true, message: nil }
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
          user: {
            email: "user@example.com",
            username: "johndoe",
            password: "SecurePass123",
            birth_date: "1990-01-15",
            email_verified: "true",
            external_id: "550e8400-e29b-41d4-a716-446655440000"
          }
        }
      end

      it { expect { perform }.not_to raise_error }
    end

    context "when version is 2" do
      let(:version) { "2" }

      let(:params) do
        {
          user: {
            email: "user@example.com",
            username: "johndoe",
            password: "SecurePass123",
            role: "user",
            recovery_email: "recovery@example.com",
            birth_date: "1990-01-15",
            preferred_notification_time: "10:30:00",
            email_verified: "false",
            session_duration: "PT2H",
            external_id: "550e8400-e29b-41d4-a716-446655440000"
          }
        }
      end

      it { expect { perform }.not_to raise_error }
    end
  end

  context "when required data for work is invalid" do
    context "when version is 1" do
      let(:version) { "1" }

      describe "because email has invalid format" do
        let(:params) do
          {
            user: {
              email: "invalid-email",
              username: "johndoe",
              password: "SecurePass123"
            }
          }
        end

        it :aggregate_failures do
          expect { perform }.to(
            raise_error do |exception|
              expect(exception).to be_a(Treaty::Exceptions::Validation)
              expect(exception.message).to(
                eq("Attribute 'email' has invalid email format: 'invalid-email'")
              )
            end
          )
        end
      end

      describe "because password has invalid format" do
        let(:params) do
          {
            user: {
              email: "user@example.com",
              username: "johndoe",
              password: "weak"
            }
          }
        end

        it :aggregate_failures do
          expect { perform }.to(
            raise_error do |exception|
              expect(exception).to be_a(Treaty::Exceptions::Validation)
              expect(exception.message).to(
                eq("Password must be 8-16 characters with at least one digit, lowercase, and uppercase letter")
              )
            end
          )
        end
      end

      describe "because birth_date has invalid format" do
        let(:params) do
          {
            user: {
              email: "user@example.com",
              username: "johndoe",
              password: "SecurePass123",
              birth_date: "not-a-date"
            }
          }
        end

        it :aggregate_failures do
          expect { perform }.to(
            raise_error do |exception|
              expect(exception).to be_a(Treaty::Exceptions::Validation)
              expect(exception.message).to(
                eq("Attribute 'birth_date' has invalid date format: 'not-a-date'")
              )
            end
          )
        end
      end

      describe "because email_verified has invalid format" do
        let(:params) do
          {
            user: {
              email: "user@example.com",
              username: "johndoe",
              password: "SecurePass123",
              email_verified: "yes"
            }
          }
        end

        it :aggregate_failures do
          expect { perform }.to(
            raise_error do |exception|
              expect(exception).to be_a(Treaty::Exceptions::Validation)
              expect(exception.message).to(
                eq("Attribute 'email_verified' has invalid boolean format: 'yes'")
              )
            end
          )
        end
      end

      describe "because external_id has invalid UUID format" do
        let(:params) do
          {
            user: {
              email: "user@example.com",
              username: "johndoe",
              password: "SecurePass123",
              external_id: "not-a-uuid"
            }
          }
        end

        it :aggregate_failures do
          expect { perform }.to(
            raise_error do |exception|
              expect(exception).to be_a(Treaty::Exceptions::Validation)
              expect(exception.message).to(
                eq("Attribute 'external_id' has invalid uuid format: 'not-a-uuid'")
              )
            end
          )
        end
      end
    end

    context "when version is 2" do
      let(:version) { "2" }

      describe "because session_duration has invalid format" do
        let(:params) do
          {
            user: {
              email: "user@example.com",
              username: "johndoe",
              password: "SecurePass123",
              role: "user",
              session_duration: "invalid duration"
            }
          }
        end

        it :aggregate_failures do
          expect { perform }.to(
            raise_error do |exception|
              expect(exception).to be_a(Treaty::Exceptions::Validation)
              expect(exception.message).to(
                eq("Attribute 'session_duration' has invalid duration format: 'invalid duration'")
              )
            end
          )
        end
      end

      describe "because preferred_notification_time has invalid format" do
        let(:params) do
          {
            user: {
              email: "user@example.com",
              username: "johndoe",
              password: "SecurePass123",
              role: "user",
              preferred_notification_time: "not-a-time"
            }
          }
        end

        it :aggregate_failures do
          expect { perform }.to(
            raise_error do |exception|
              expect(exception).to be_a(Treaty::Exceptions::Validation)
              expect(exception.message).to(
                eq("Attribute 'preferred_notification_time' has invalid time format: 'not-a-time'")
              )
            end
          )
        end
      end
    end
  end
end
