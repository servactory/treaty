# frozen_string_literal: true

module Gate
  module API
    module Posts
      class CreateTreaty < ApplicationTreaty
        version 1 do # Also supported: 1.0, 1.0.0.rc1
          summary "The first version of the contract for creating a post"

          strategy Treaty::Strategy::DIRECT

          deprecated do # as block (proc)
            Gem::Version.new(ENV.fetch("RELEASE_VERSION", "0.0.0")) >=
              Gem::Version.new("17.0.0")
          end

          request       { scope :post }
          response(201) { scope :post }

          # Present: title, summary. Missing: description.
          delegate_to ::Posts::V1::CreateService # , :call
        end

        version 2 do # Also supported: 2.0, 2.0.0.rc1
          summary "Added middle name to expand post data"

          strategy Treaty::Strategy::ADAPTER

          deprecated(lambda do # as lambda (proc)
            Gem::Version.new(ENV.fetch("RELEASE_VERSION", "0.0.0")) >=
              Gem::Version.new("18.0.0")
          end)

          request do
            scope :post do
              string :title, :required
              string :summary, :required
              string :description, :optional
              string :content, :required
            end
          end

          response 201 do
            scope :post do
              string :id
              string :title
              string :summary
              string :description
              string :content
            end
          end

          # delegate_to ::Posts::Stable::CreateService # , :call
          delegate_to "Posts::Stable::CreateService" # , :call
        end

        version 3 do # Also supported: 3.0, 3.0.0.rc1
          summary "Added author and socials to expand post data"

          strategy Treaty::Strategy::ADAPTER

          request do
            # Query
            scope :self do # should be perceived as root
              string :signature, :required
            end
          end

          request do
            # Body
            scope :post do
              string :title, :required
              string :summary, :required
              string :description, :optional
              string :content, :required

              object :author, :required do
                string :name, :required
                string :bio, :required

                array :socials, :optional do
                  string :provider, :required, in: %w[twitter linkedin github]
                  string :handle, :required, as: :value
                end
              end
            end
          end

          response 201 do
            scope :post do
              string :id
              string :title
              string :summary
              string :description
              string :content

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

              datetime :created_at
              datetime :updated_at
            end
          end

          # delegate_to ::Posts::Stable::CreateService # , :call
          delegate_to "posts/stable/create_service" # , :call
        end
      end
    end
  end
end
