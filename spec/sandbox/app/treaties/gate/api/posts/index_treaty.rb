# frozen_string_literal: true

module Gate
  module API
    module Posts
      class IndexTreaty < ApplicationTreaty # rubocop:disable Metrics/ClassLength
        version [1, 0, 0, :rc1] do # Just to keep the idea going.
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
            array :posts
            object :meta
          end

          # Present: title, summary. Missing: middle_name.
          delegate_to ::Posts::V1::IndexService

          # Full example:
          # delegate_to ::Posts::V1::IndexService => :call, return: lambda(&:data)
        end

        version "1.0.0.rc2" do # Just to keep the idea going.
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
            array :posts
            object :meta
          end

          # Present: title, summary. Missing: middle_name.
          delegate_to ::Posts::V1::IndexService

          # Full example:
          # delegate_to ::Posts::V1::IndexService => :call, return: lambda(&:data)
        end

        version 1 do # Also supported: 1.0, 1.0.0.rc1
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
            array :posts
            object :meta
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
          request do
            # Query: filters[title], filters[middle_name], filters[summary]
            object :filters, :optional do
              string :title, :optional
              string :summary, :optional
              string :description, :optional
            end
          end

          response 200 do
            array :posts do
              string :id
              string :title
              string :summary
              string :description
              string :content
            end

            object :meta do
              integer :count
              integer :page
              integer :limit
            end
          end

          delegate_to ::Posts::Stable::IndexService

          # Full example:
          # delegate_to ::Posts::Stable::IndexService => :call, return: lambda(&:data)
        end

        version 3 do # Also supported: 2.0, 2.0.0.rc1
          request do
            # Query: filters[title], filters[middle_name], filters[summary]
            object :filters, :optional do
              string :title, :optional, transform: ->(value:) { value.strip.downcase }
              string :summary, :optional
              string :description, :optional
            end
          end

          response 200 do
            array :posts do
              string :id
              string :title
              string :summary
              string :description
              string :content
            end

            object :meta do
              integer :count
              integer :page
              integer :limit, default: 12
            end
          end

          delegate_to ::Posts::Stable::IndexService

          # Full example:
          # delegate_to ::Posts::Stable::IndexService => :call, return: lambda(&:data)
        end

        version 4, default: true do
          request Gate::API::Posts::FiltersEntity

          response 200, Gate::API::Posts::IndexEntity

          delegate_to ::Posts::Stable::IndexService

          # Full example:
          # delegate_to ::Posts::Stable::IndexService => :call, return: lambda(&:data)
        end

        version 5 do
          summary "Demonstrates type casting functionality"
          request do
            object :filters, :optional do
              string :title, :optional, transform: ->(value:) { value.strip.downcase }
              string :summary, :optional
              string :description, :optional
              # Cast boolean string to actual boolean
              string :published, :optional, cast: :boolean
              # Cast Unix timestamp to datetime
              integer :created_after, :optional, cast: :datetime
            end
          end

          response 200 do
            array :posts do
              string :id
              string :title
              string :summary
              string :description
              string :content
              # Cast datetime to Unix timestamp for efficient API transfer
              time :created_at, cast: :integer
            end

            object :meta do
              integer :count
              integer :page
              integer :limit, default: 12
            end
          end

          delegate_to ::Posts::Stable::IndexService
        end

        version 6 do
          summary "Demonstrates date, time, and datetime types with casting"
          request do
            object :filters, :optional do
              string :title, :optional, transform: ->(value:) { value.strip.downcase }
              string :summary, :optional
              string :description, :optional
              # Cast date string to Date object
              string :published_on, :optional, cast: :date
              # Cast time string to Time object
              string :created_at, :optional, cast: :time
              # Cast Unix timestamp to datetime
              integer :updated_after, :optional, cast: :datetime
            end
          end

          response 200 do
            array :posts do
              string :id
              string :title
              string :summary
              string :description
              string :content
              # Cast Date to string for API response
              date :published_on, cast: :string
              # Cast Time to Unix timestamp
              time :created_at, cast: :integer
              # Cast DateTime to ISO8601 string
              time :updated_at, cast: :string
            end

            object :meta do
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
