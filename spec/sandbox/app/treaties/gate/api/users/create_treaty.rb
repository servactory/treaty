# frozen_string_literal: true

module Gate
  module API
    module Users
      class CreateTreaty < ApplicationTreaty
        version 1 do # Also supported: 1.0, 1.0.0.rc1
          summary "The first version of the contract for creating a user"

          strategy :direct

          deprecated do # as block (proc)
            Gem::Version.new(ENV.fetch("RELEASE_VERSION", nil)) >=
              Gem::Version.new("17.0.0")
          end

          request :user
          response :user, 201

          # Present: first_name, last_name. Missing: middle_name.
          delegate_to ::Users::V1::CreateService
        end

        version 2 do # Also supported: 2.0, 2.0.0.rc1
          summary "Added middle name to expand user data"

          strategy :adapter

          deprecated(lambda do # as lambda (proc)
            Gem::Version.new(ENV.fetch("RELEASE_VERSION", nil)) >=
              Gem::Version.new("18.0.0")
          end)

          request :user do
            string :first_name, :string, :required
            string :middle_name, :string, :optional
            string :last_name, :string, :required
          end

          response :user, 201 do
            string :id
            string :first_name
            string :middle_name
            string :last_name
          end

          delegate_to ::Users::Stable::CreateService
        end

        version 3 do # Also supported: 3.0, 3.0.0.rc1
          summary "Added address and socials to expand user data"

          strategy :adapter

          request :user do
            # Query
            string :signature, :required

            # Body
            string :first_name, :required
            string :middle_name, :optional
            string :last_name, :required

            object :address, :required do
              string :street, :required
              string :city, :required
              string :state, :required
              string :zipcode, :required
            end

            array :socials, :optional do
              string :provider, :required, in: %w[twitter linkedin github]
              string :handle, :required, as: :value
            end
          end

          response :user, 201 do
            string :id
            string :first_name
            string :middle_name
            string :last_name

            object :address do
              string :street
              string :city
              string :state
              string :zipcode
            end

            datetime :created_at
            datetime :updated_at
          end

          delegate_to ::Users::Stable::CreateService
        end
      end
    end
  end
end
