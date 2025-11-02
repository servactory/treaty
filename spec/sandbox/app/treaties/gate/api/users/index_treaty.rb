# frozen_string_literal: true

module Gate
  module API
    module Users
      class IndexTreaty < ApplicationTreaty
        version [1, 0, 0, :rc1] do # Just to keep the idea going.
          strategy :direct

          deprecated true # as boolean

          # Query: filters[first_name], filters[middle_name], filters[last_name]
          request :filters do
            string :first_name, :string, :optional
            string :middle_name, :string, :optional
            string :last_name, :string, :optional
          end

          response :users, 200

          # Present: first_name, last_name. Missing: middle_name.
          delegate_to ::Users::V1::IndexService
        end

        version "1.0.0.rc2" do # Just to keep the idea going.
          strategy :direct

          deprecated true # as boolean

          # Query: filters[first_name], filters[middle_name], filters[last_name]
          request :filters do
            string :first_name, :string, :optional
            string :middle_name, :string, :optional
            string :last_name, :string, :optional
          end

          response :users, 200

          # Present: first_name, last_name. Missing: middle_name.
          delegate_to ::Users::V1::IndexService
        end

        version 1 do # Also supported: 1.0, 1.0.0.rc1
          strategy :direct

          deprecated( # as boolean
            Gem::Version.new(ENV.fetch("RELEASE_VERSION", nil)) >=
              Gem::Version.new("17.0.0")
          )

          # Query: filters[first_name], filters[middle_name], filters[last_name]
          request :filters do
            string :first_name, :string, :optional
            string :middle_name, :string, :optional
            string :last_name, :string, :optional
          end

          response :users, 200

          # Present: first_name, last_name. Missing: middle_name.
          delegate_to ::Users::V1::IndexService
        end

        version 2 do # Also supported: 2.0, 2.0.0.rc1
          strategy :adapter

          # Query: filters[first_name], filters[middle_name], filters[last_name]
          request :filters do
            string :first_name, :string, :optional
            string :middle_name, :string, :optional
            string :last_name, :string, :optional
          end

          response :users, 200 do
            string :id
            string :first_name
            string :middle_name
            string :last_name
          end

          delegate_to ::Users::Stable::IndexService
        end
      end
    end
  end
end
