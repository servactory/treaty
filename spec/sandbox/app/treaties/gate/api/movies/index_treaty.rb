# frozen_string_literal: true

module Gate
  module API
    module Movies
      class IndexTreaty < ApplicationTreaty
        version [1, 0, 0, :rc1] do
          summary "List of movies"

          strategy Treaty::Strategy::DIRECT

          request do
            object :filters, :optional do
              integer :year, :optional
              integer :rating, :optional
            end
          end

          response 200 do
            array :movies
            object :meta
          end

          delegate_to ::Movies::V1::IndexService
        end

        version 2 do
          summary "Added genre filter and details"

          strategy Treaty::Strategy::ADAPTER

          deprecated(lambda do
            Gem::Version.new(ENV.fetch("RELEASE_VERSION", "0.0.0")) >=
              Gem::Version.new("3.0.0")
          end)

          request do
            object :filters, :optional do
              string :title, :optional
              integer :year, :optional
              string :genre, :optional, in: %w[crime thriller action drama western]
              integer :min_rating, :optional
            end
          end

          response 200 do
            array :movies do
              string :id
              string :title
              integer :year
              string :genre
              integer :runtime
              string :plot
            end

            object :meta do
              integer :count
              integer :page
              integer :total_pages
            end
          end

          delegate_to ::Movies::Stable::IndexService
        end

        version 3, default: true do
          summary "Added cast and awards"

          strategy Treaty::Strategy::ADAPTER

          request do
            object :filters, :optional do
              string :title, :optional
              integer :year, :optional
              string :genre, :optional, in: %w[crime thriller action drama western]
              integer :min_rating, :optional
              boolean :include_cast, :optional
            end
          end

          response 200 do
            array :movies do
              string :id
              string :title
              integer :year
              string :genre
              integer :runtime
              string :plot
              integer :rating

              array :cast, :optional do
                string :actor
                string :character
                boolean :lead_role
              end

              object :awards, :optional do
                integer :oscars
                integer :golden_globes
                integer :baftas
              end

              datetime :released_at
            end

            object :meta do
              integer :count
              integer :page
              integer :total_pages
              integer :limit, default: 15
            end
          end

          delegate_to(lambda do |params:|
            # Custom filtering logic for films
            params
          end)
        end
      end
    end
  end
end
