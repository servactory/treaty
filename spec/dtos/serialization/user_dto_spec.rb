# frozen_string_literal: true

RSpec.describe Serialization::UserDto do
  it_behaves_like "check treaty entity info",
                  attributes: {
                    user: {
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
                      },
                      options: {
                        required: { is: true, message: nil }
                      },
                      type: :object
                    }
                  }
end
