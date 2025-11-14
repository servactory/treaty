# frozen_string_literal: true

module Gate
  module API
    module Users
      class CreateTreaty < ApplicationTreaty
        version 1 do
          summary "User creation with format validation examples"

          strategy Treaty::Strategy::ADAPTER

          request do
            object :user do
              # Example: email format validation
              string :email, format: :email

              string :username

              # Example: password format validation with custom message
              string :password,
                     format: {
                       is: :password,
                       message: "Password must be 8-16 characters with at least one digit, " \
                                "lowercase, and uppercase letter"
                     }

              # Example: optional fields with format validation
              string :recovery_email,
                     :optional,
                     format: { is: :email, message: "Recovery email must be valid" }

              string :birth_date, :optional, format: :date
              string :preferred_notification_time, :optional, format: :time

              # Example: boolean format validation
              string :email_verified, :optional, format: :boolean

              # Example: UUID format validation
              string :external_id, :optional, format: :uuid
            end
          end

          response 201 do
            object :user do
              string :id
              string :email, format: :email
              string :username
              string :recovery_email, :optional, format: :email
              string :birth_date, :optional, format: :date
              string :preferred_notification_time, :optional, format: :time
              string :email_verified, format: :boolean
              string :external_id, :optional, format: :uuid
              datetime :created_at
              datetime :updated_at
            end
          end

          delegate_to "Users::CreateService"
        end

        version 2 do
          summary "Extended user creation with Entity-based definition"

          strategy Treaty::Strategy::ADAPTER

          request do
            use_entity Deserialization::UserDto
          end

          response 201 do
            use_entity Serialization::UserDto
          end

          delegate_to "Users::CreateService"
        end
      end
    end
  end
end
