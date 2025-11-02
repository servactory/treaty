# frozen_string_literal: true

module Gate
  module API
    module Users
      class IndexTreaty < ApplicationTreaty
        version [1, 0, 0, :rc1] do # Just to keep the idea going.
          strategy Treaty::Strategy::DIRECT

          deprecated true # as boolean

          request do
            # Query: filters[first_name], filters[middle_name], filters[last_name]
            scope :filters do
              string :first_name, :string, :optional
              string :middle_name, :string, :optional
              string :last_name, :string, :optional
            end
          end

          response 200 do
            scope :users
            scope :meta
          end

          # Present: first_name, last_name. Missing: middle_name.
          delegate_to ::Users::V1::IndexService
        end

        version "1.0.0.rc2" do # Just to keep the idea going.
          strategy Treaty::Strategy::DIRECT

          deprecated true # as boolean

          request do
            # Query: filters[first_name], filters[middle_name], filters[last_name]
            scope :filters do
              string :first_name, :string, :optional
              string :middle_name, :string, :optional
              string :last_name, :string, :optional
            end
          end

          response 200 do
            scope :users
            scope :meta
          end

          # Present: first_name, last_name. Missing: middle_name.
          delegate_to ::Users::V1::IndexService
        end

        version 1 do # Also supported: 1.0, 1.0.0.rc1
          strategy Treaty::Strategy::DIRECT

          deprecated( # as boolean
            Gem::Version.new(ENV.fetch("RELEASE_VERSION", "0.0.0")) >=
              Gem::Version.new("17.0.0")
          )

          request do
            # Query: filters[first_name], filters[middle_name], filters[last_name]
            scope :filters do
              string :first_name, :string, :optional
              string :middle_name, :string, :optional
              string :last_name, :string, :optional
            end
          end

          response 200 do
            scope :users
            scope :meta
          end

          # Present: first_name, last_name. Missing: middle_name.
          delegate_to ::Users::V1::IndexService
        end

        version 2 do # Also supported: 2.0, 2.0.0.rc1
          strategy Treaty::Strategy::ADAPTER

          # TODO: An idea on how to simplify while maintaining power:
          #       - When one scope:
          #         - request(:user) { string :first_name }
          #         - response(:user, 200) { string :first_name }
          #       - When multiple scopes:
          #         - requests { scope(:user) { string :first_name } }
          #         - responses(200) { scope(:user) { string :first_name } }
          request do
            # Query: filters[first_name], filters[middle_name], filters[last_name]
            scope :filters do
              string :first_name, :string, :optional
              string :middle_name, :string, :optional
              string :last_name, :string, :optional
            end
          end

          response 200 do
            scope :users do
              string :id
              string :first_name
              string :middle_name
              string :last_name
            end

            scope :meta do
              integer :count
              integer :page
              integer :limit
            end
          end

          delegate_to ::Users::Stable::IndexService
        end
      end
    end
  end
end
