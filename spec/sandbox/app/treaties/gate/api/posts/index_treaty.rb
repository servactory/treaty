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
            object :filters, :optional do
              string :title, :optional
              string :summary, :optional
              string :description, :optional
            end
          end

          response 200 do
            object :posts, :optional
            object :meta, :optional
          end

          # Present: title, summary. Missing: middle_name.
          delegate_to ::Posts::V1::IndexService

          # Full example:
          # delegate_to ::Posts::V1::IndexService => :call, return: lambda(&:data)
        end

        version "1.0.0.rc2" do # Just to keep the idea going.
          strategy Treaty::Strategy::DIRECT

          deprecated true # as boolean

          request do
            # Query: filters[title], filters[middle_name], filters[summary]
            object :filters, :optional do
              string :title, :optional
              string :summary, :optional
              string :description, :optional
            end
          end

          response 200 do
            object :posts, :optional
            object :meta, :optional
          end

          # Present: title, summary. Missing: middle_name.
          delegate_to ::Posts::V1::IndexService

          # Full example:
          # delegate_to ::Posts::V1::IndexService => :call, return: lambda(&:data)
        end

        version 1 do # Also supported: 1.0, 1.0.0.rc1
          strategy Treaty::Strategy::DIRECT

          deprecated( # as boolean
            Gem::Version.new(ENV.fetch("RELEASE_VERSION", "0.0.0")) >=
              Gem::Version.new("17.0.0")
          )

          request do
            # Query: filters[title], filters[middle_name], filters[summary]
            object :filters, :optional do
              string :title, :optional
              string :summary, :optional
              string :description, :optional
            end
          end

          response 200 do
            object :posts, :optional
            object :meta, :optional
          end

          # Present: title, summary. Missing: middle_name.
          delegate_to(lambda do |params:|
            # NOTE: To avoid using the service for any reason,
            #       use Proc to work with params locally.
            params
          end)

          # Full example:
          # delegate_to(lambda do |params:|
          #   params
          # end => :call, return: lambda(&:data))
        end

        version 2 do # Also supported: 2.0, 2.0.0.rc1
          strategy Treaty::Strategy::ADAPTER

          # TODO: An idea on how to simplify while maintaining power:
          #       - When one object:
          #         - request(:post) { string :title }
          #         - response(:post, 200) { string :title }
          #       - When multiple objects:
          #         - requests { object(:post) { string :title } }
          #         - responses(200) { object(:post) { string :title } }
          request do
            # Query: filters[title], filters[middle_name], filters[summary]
            object :filters, :optional do
              string :title, :optional
              string :summary, :optional
              string :description, :optional
            end
          end

          response 200 do
            object :posts, :optional do
              string :id
              string :title
              string :summary
              string :description
              string :content
            end

            object :meta, :optional do
              integer :count
              integer :page
              integer :limit
            end
          end

          delegate_to ::Posts::Stable::IndexService

          # Full example:
          # delegate_to ::Posts::Stable::IndexService => :call, return: lambda(&:data)
        end

        version 3, default: true do # Also supported: 2.0, 2.0.0.rc1
          strategy Treaty::Strategy::ADAPTER

          # TODO: An idea on how to simplify while maintaining power:
          #       - When one object:
          #         - request(:post) { string :title }
          #         - response(:post, 200) { string :title }
          #       - When multiple objects:
          #         - requests { object(:post) { string :title } }
          #         - responses(200) { object(:post) { string :title } }
          request do
            # Query: filters[title], filters[middle_name], filters[summary]
            object :filters, :optional do
              string :title, :optional
              string :summary, :optional
              string :description, :optional
            end
          end

          response 200 do
            object :posts, :optional do
              string :id
              string :title
              string :summary
              string :description
              string :content
            end

            object :meta, :optional do
              integer :count
              integer :page
              integer :limit, default: 12
            end
          end

          delegate_to ::Posts::Stable::IndexService

          # Full example:
          # delegate_to ::Posts::Stable::IndexService => :call, return: lambda(&:data)
        end
      end
    end
  end
end
