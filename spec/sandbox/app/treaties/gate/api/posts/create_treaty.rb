# frozen_string_literal: true

module Gate
  module API
    module Posts
      class CreateTreaty < ApplicationTreaty # rubocop:disable Metrics/ClassLength
        version 1 do # Also supported: 1.0, 1.0.0.rc1
          summary "The first version of the contract for creating a post"

          deprecated do # as block (proc)
            Gem::Version.new(ENV.fetch("RELEASE_VERSION", "0.0.0")) >=
              Gem::Version.new("17.0.0")
          end

          request       { object :post }
          response(201) { object :post }

          # Present: title, summary. Missing: description.
          delegate_to ::Posts::V1::CreateService

          # Full example:
          # delegate_to ::Posts::V1::CreateService => :call, return: lambda(&:data)
        end

        version 2 do # Also supported: 2.0, 2.0.0.rc1
          summary "Added middle name to expand post data"

          deprecated(lambda do # as lambda (proc)
            Gem::Version.new(ENV.fetch("RELEASE_VERSION", "0.0.0")) >=
              Gem::Version.new("18.0.0")
          end)

          request do
            object :post, :optional do
              string :title
              string :summary
              string :description, :optional
              string :content
            end
          end

          response 201 do
            object :post do
              string :id
              string :title
              string :summary
              string :description
              string :content
            end
          end

          delegate_to "Posts::Stable::CreateService"

          # Full example:
          # delegate_to "Posts::Stable::CreateService" => :call, return: lambda(&:data)
        end

        version 3 do # Also supported: 3.0, 3.0.0.rc1
          summary "Added author and socials to expand post data"

          request do
            # Query
            object :_self do # should be perceived as root
              string :signature
            end
          end

          request do
            # Body
            object :post do
              string :title, transform: ->(value:) { value.strip }
              string :summary
              string :description, :optional
              string :content
              boolean :published, :optional

              array :tags, :optional do
                string :_self, transform: ->(value:) { value.downcase }
              end

              object :author do
                string :name
                string :bio

                array :socials, :optional do
                  string :provider, in: %w[twitter linkedin github]
                  string :handle, as: :value
                end
              end
            end
          end

          response 201 do
            object :post do
              string :id
              string :title
              string :summary
              string :description
              string :content
              boolean :published
              boolean :featured

              array :tags do
                string :_self
              end

              object :author do
                string :name
                string :bio

                array :socials do
                  string :provider
                  string :value, as: :handle
                end
              end

              integer :rating
              integer :views

              time :created_at
              time :updated_at
            end
          end

          delegate_to "posts/stable/create_service"

          # Full example:
          # delegate_to "posts/stable/create_service" => :call, return: lambda(&:data)
        end

        version 4 do
          summary "Demonstrates type casting functionality"

          request do
            # Query
            object :_self do
              string :signature
            end
          end

          request do
            # Body
            object :post do
              string :title, transform: ->(value:) { value.strip }
              string :summary
              string :description, :optional
              string :content
              boolean :published, :optional

              # Cast string timestamp to datetime
              string :published_at, :optional, cast: :datetime

              array :tags, :optional do
                string :_self, transform: ->(value:) { value.downcase }
              end

              object :author do
                string :name
                string :bio

                array :socials, :optional do
                  string :provider, in: %w[twitter linkedin github]
                  string :handle, as: :value
                end
              end
            end
          end

          response 201 do
            object :post do
              string :id
              string :title
              string :summary
              string :description
              string :content
              boolean :published
              boolean :featured

              # Cast datetime to string for API output
              datetime :published_at, cast: :string

              array :tags do
                string :_self
              end

              object :author do
                string :name
                string :bio

                array :socials do
                  string :provider
                  string :value, as: :handle
                end
              end

              integer :rating
              integer :views

              # Cast datetime to integer (Unix timestamp)
              time :created_at, cast: :integer
              time :updated_at, cast: :string
            end
          end

          delegate_to "posts/stable/create_service"
        end

        version 5 do
          summary "Demonstrates date, time, and datetime types with casting"

          request do
            # Query
            object :_self do
              string :signature
            end
          end

          request do
            # Body
            object :post do
              string :title, transform: ->(value:) { value.strip }
              string :summary
              string :description, :optional
              string :content
              boolean :published, :optional

              # Cast date string to Date object
              string :published_on, :optional, cast: :date

              # Cast time string to Time object
              string :scheduled_at, :optional, cast: :time

              array :tags, :optional do
                string :_self, transform: ->(value:) { value.downcase }
              end

              object :author do
                string :name
                string :bio

                array :socials, :optional do
                  string :provider, in: %w[twitter linkedin github]
                  string :handle, as: :value
                end
              end
            end
          end

          response 201 do
            object :post do
              string :id
              string :title
              string :summary
              string :description
              string :content
              boolean :published
              boolean :featured

              # Cast Date to string for API response
              date :published_on, cast: :string

              # Cast Time to Unix timestamp
              time :scheduled_at, cast: :integer

              array :tags do
                string :_self
              end

              object :author do
                string :name
                string :bio

                array :socials do
                  string :provider
                  string :value, as: :handle
                end
              end

              integer :rating
              integer :views

              # DateTime casts
              time :created_at, cast: :string
              time :updated_at, cast: :integer
            end
          end

          delegate_to "posts/stable/create_service"
        end

        version 6 do
          summary "Demonstrates conditional attributes with if option"

          request do
            # Query
            object :_self do
              string :signature
            end
          end

          request do
            # Body
            object :post do
              string :title, transform: ->(value:) { value.strip }
              string :summary
              string :description, :optional
              string :content
              boolean :published, :optional

              # published_at determines visibility of other fields
              string :published_at, :optional, cast: :datetime

              # Tags only accepted if post is published
              array :tags, :optional, if: ->(**attrs) { attrs.dig(:post, :published_at).present? } do
                string :_self, transform: ->(value:) { value.downcase }
              end

              object :author do
                string :name
                string :bio

                array :socials, :optional do
                  string :provider, in: %w[twitter linkedin github]
                  string :handle, as: :value
                end
              end
            end
          end

          response 201 do
            object :post do
              string :id
              string :title
              string :summary
              string :description
              string :content
              boolean :published
              boolean :featured

              datetime :published_at, cast: :string

              # Tags only visible if post is published
              array :tags, if: ->(**attrs) { attrs.dig(:post, :published_at).present? } do
                string :_self
              end

              object :author do
                string :name
                string :bio

                array :socials do
                  string :provider
                  string :value, as: :handle
                end
              end

              # Rating and views only visible for published posts
              integer :rating, if: ->(post:) { post[:published_at].present? }
              integer :views, if: ->(post:) { post[:published_at].present? }

              time :created_at, cast: :string
              time :updated_at, cast: :integer
            end
          end

          delegate_to "posts/stable/create_service"
        end
      end
    end
  end
end
