# frozen_string_literal: true

module Gate
  module API
    module Posts
      class IndexTreaty < ApplicationTreaty # rubocop:disable Metrics/ClassLength
        version [1, 0, 0, :rc1] do # Just to keep the idea going.
          strategy Treaty::Strategy::DIRECT

          deprecated true # as boolean

          request do
            # Query: filters[title], filters[middle_name], filters[summary]
            scope :filters do
              string :title, :optional
              string :summary, :optional
              string :description, :optional
            end
          end

          response 200 do
            scope :posts
            scope :meta
          end

          # Present: title, summary. Missing: middle_name.
          delegate_to ::Posts::V1::IndexService
        end

        version "1.0.0.rc2" do # Just to keep the idea going.
          strategy Treaty::Strategy::DIRECT

          deprecated true # as boolean

          request do
            # Query: filters[title], filters[middle_name], filters[summary]
            scope :filters do
              string :title, :optional
              string :summary, :optional
              string :description, :optional
            end
          end

          response 200 do
            scope :posts
            scope :meta
          end

          # Present: title, summary. Missing: middle_name.
          delegate_to ::Posts::V1::IndexService
        end

        version 1 do # Also supported: 1.0, 1.0.0.rc1
          strategy Treaty::Strategy::DIRECT

          deprecated( # as boolean
            Gem::Version.new(ENV.fetch("RELEASE_VERSION", "0.0.0")) >=
              Gem::Version.new("17.0.0")
          )

          request do
            # Query: filters[title], filters[middle_name], filters[summary]
            scope :filters do
              string :title, :optional
              string :summary, :optional
              string :description, :optional
            end
          end

          response 200 do
            scope :posts
            scope :meta
          end

          # Present: title, summary. Missing: middle_name.
          # delegate_to ::Posts::V1::IndexService
          delegate_to(lambda do |params|
            # NOTE: To avoid using the service for any reason,
            #       use Proc to work with params locally.
            params
          end)
        end

        version 2 do # Also supported: 2.0, 2.0.0.rc1
          strategy Treaty::Strategy::ADAPTER

          # TODO: An idea on how to simplify while maintaining power:
          #       - When one scope:
          #         - request(:post) { string :title }
          #         - response(:post, 200) { string :title }
          #       - When multiple scopes:
          #         - requests { scope(:post) { string :title } }
          #         - responses(200) { scope(:post) { string :title } }
          request do
            # Query: filters[title], filters[middle_name], filters[summary]
            scope :filters do
              string :title, :optional
              string :summary, :optional
              string :description, :optional
            end
          end

          response 200 do
            scope :posts do
              string :id
              string :title
              string :summary
              string :description
              string :content
            end

            scope :meta do
              integer :count
              integer :page
              integer :limit
            end
          end

          delegate_to ::Posts::Stable::IndexService
        end

        version 3 do # Also supported: 2.0, 2.0.0.rc1
          strategy Treaty::Strategy::ADAPTER

          # TODO: An idea on how to simplify while maintaining power:
          #       - When one scope:
          #         - request(:post) { string :title }
          #         - response(:post, 200) { string :title }
          #       - When multiple scopes:
          #         - requests { scope(:post) { string :title } }
          #         - responses(200) { scope(:post) { string :title } }
          request do
            # Query: filters[title], filters[middle_name], filters[summary]
            scope :filters do
              string :title, :optional
              string :summary, :optional
              string :description, :optional
            end
          end

          response 200 do
            scope :posts do
              string :id
              string :title
              string :summary
              string :description
              string :content
            end

            scope :meta do
              integer :count
              integer :page
              integer :limit, default: 12
            end
          end

          delegate_to ::Posts::Stable::IndexService
        end
      end
    end
  end
end
