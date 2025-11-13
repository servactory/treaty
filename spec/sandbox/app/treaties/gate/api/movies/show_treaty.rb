# frozen_string_literal: true

module Gate
  module API
    module Movies
      class ShowTreaty < ApplicationTreaty # rubocop:disable Metrics/ClassLength
        version 1 do
          summary "Show movie details"

          strategy Treaty::Strategy::DIRECT

          request do
            string :id
          end

          response 200 do
            object :movie do
              string :id
              string :title
              integer :year
              string :genre
              integer :runtime
              string :plot
            end
          end

          delegate_to ::Movies::V1::ShowService
        end

        version 2 do
          summary "Added cast and memorable scenes"

          strategy Treaty::Strategy::ADAPTER

          deprecated false

          request do
            string :id
            boolean :include_cast, :optional
            boolean :include_scenes, :optional
          end

          response 200 do
            object :movie do
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
                string :role_type
                boolean :lead_role
              end

              array :scenes, :optional do
                string :title
                string :location
                integer :duration
              end
            end
          end

          delegate_to "Movies::Stable::ShowService"
        end

        version 3, default: true do
          summary "Added soundtrack and trivia"

          strategy Treaty::Strategy::ADAPTER

          request do
            object :_self do
              string :api_key
            end
          end

          request do
            string :id
            boolean :include_cast, :optional
            boolean :include_scenes, :optional
            boolean :include_soundtrack, :optional
          end

          response 200 do
            object :movie do
              string :id
              string :title
              integer :year
              string :genre
              integer :runtime
              string :plot
              integer :rating
              boolean :cult_classic
              boolean :contains_violence

              array :cast do
                string :actor
                string :character
                string :role_type
                boolean :lead_role
                integer :screen_time
              end

              array :scenes do
                string :title
                string :location
                integer :duration
                boolean :iconic
              end

              object :soundtrack, :optional do
                array :tracks do
                  string :title
                  string :artist
                  string :album, as: :source
                  integer :year
                end
              end

              object :awards do
                integer :oscars
                integer :golden_globes
                integer :cannes_awards
              end

              array :trivia, :optional do
                string :_self
              end

              object :production do
                string :studio
                string :director
                integer :budget
                integer :box_office, as: :revenue
              end

              datetime :released_at
              datetime :updated_at
            end
          end

          delegate_to "movies/stable/show_service"
        end
      end
    end
  end
end
