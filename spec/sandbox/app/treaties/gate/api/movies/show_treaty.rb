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
              # Example: required with custom string message
              string :api_key, required: { is: true, message: "API key is required for authentication" }
            end
          end

          request do
            # Example: required with custom lambda message
            string :id, required: {
              is: true,
              message: ->(attribute:, **) { "Movie #{attribute} must be provided" }
            }

            boolean :include_cast, :optional
            boolean :include_scenes, :optional
            boolean :include_soundtrack, :optional
          end

          response 200 do
            object :movie do
              string :id
              string :title

              # Example: type validation with custom string message (implicitly applied through attribute type)
              integer :year

              # Example: inclusion with custom string message (simple mode for in, advanced for message)
              string :genre,
                     in: %w[action comedy drama horror sci-fi thriller crime],
                     required: { is: true, message: "Genre must be specified" }

              integer :runtime

              # Example: required with custom lambda message for response
              string :plot, required: {
                is: true,
                message: lambda do |attribute:, value:, **|
                  "The #{attribute} field is mandatory (received: #{value.inspect})"
                end
              }

              # Example: inclusion with custom lambda message (advanced mode)
              integer :rating,
                      inclusion: {
                        in: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
                        message: lambda do |attribute:, value:, allowed_values:, **|
                          "Invalid #{attribute}: #{value}. " \
                            "Must be between #{allowed_values.min} and #{allowed_values.max}"
                        end
                      }

              boolean :cult_classic
              boolean :contains_violence

              array :cast do
                string :actor
                string :character

                # Example: inclusion with custom lambda in nested array
                string :role_type,
                       inclusion: {
                         in: %w[lead supporting cameo protagonist],
                         message: ->(value:, **) { "Role type '#{value}' is not recognized" }
                       }

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
