# frozen_string_literal: true

# Unified UserEntity combining attributes from Deserialization and Serialization DTOs.
# Use with .call(data, required: true) for request validation (strict)
# Use with .call(data, required: false) for response serialization (lenient)
class UserEntity < ApplicationEntity
  object :user do
    # Response-only field
    string :id, :optional

    # Example: format validation with simple mode
    string :email, format: :email

    # Example: format validation with advanced mode and custom message
    string :username,
           required: { is: true, message: "Username is required" }

    # Example: optional field with format validation
    string :recovery_email,
           :optional,
           format: { is: :email, message: "Recovery email must be a valid email address" }

    # Example: password format with custom lambda message
    string :password,
           format: {
             is: :password,
             message: lambda do |attribute:, **|
               "#{attribute.to_s.capitalize} must be 8-16 characters with at least one digit, " \
                 "lowercase, and uppercase letter"
             end
           }

    string :role, :optional, in: %w[admin user guest], default: { is: "user" }

    # Example: datetime format validation
    string :last_login_at, :optional, format: :datetime

    # Example: date format validation
    string :birth_date, :optional, format: :date

    # Example: time format validation
    string :preferred_notification_time, :optional, format: :time

    # Example: boolean format validation
    string :email_verified, :optional, format: :boolean, default: { is: "false" }

    # Example: duration format validation (e.g., "1 day", "2 hours")
    string :session_duration, :optional, format: :duration

    # Example: UUID format validation
    string :external_id, :optional, format: :uuid

    # Response-only fields: cast time to string for API response
    time :created_at, :optional, cast: :string
    time :updated_at, :optional, cast: :string
  end
end
