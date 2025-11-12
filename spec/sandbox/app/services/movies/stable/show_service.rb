# frozen_string_literal: true

module Movies
  module Stable
    class ShowService < ApplicationService::Base
      input :params, type: Hash, required: false, default: {}

      output :data, type: Hash

      private

      def call # rubocop:disable Metrics/MethodLength
        outputs.data = {
          movie: {
            id: inputs.params[:id] || SecureRandom.uuid,
            title: "Pulp Fiction",
            year: 1994,
            genre: "crime",
            runtime: 154,
            plot: "Interconnected criminal stories",
            rating: 9,
            cult_classic: true,
            contains_violence: true,
            cast: [
              {
                actor: "John Travolta",
                character: "Vincent Vega",
                role_type: "protagonist",
                lead_role: true,
                screen_time: 45
              },
              {
                actor: "Uma Thurman",
                character: "Mia Wallace",
                role_type: "supporting",
                lead_role: true,
                screen_time: 30
              },
              {
                actor: "Samuel L. Jackson",
                character: "Jules Winnfield",
                role_type: "protagonist",
                lead_role: true,
                screen_time: 50
              }
            ],
            scenes: [
              {
                title: "Jack Rabbit Slims",
                location: "Restaurant",
                duration: 12,
                iconic: true
              },
              {
                title: "Ezekiel 25:17",
                location: "Apartment",
                duration: 5,
                iconic: true
              }
            ],
            soundtrack: {
              tracks: [
                {
                  title: "Misirlou",
                  artist: "Dick Dale",
                  source: "Single",
                  year: 1962
                },
                {
                  title: "Girl You'll Be a Woman Soon",
                  artist: "Urge Overkill",
                  source: "Saturation",
                  year: 1993
                }
              ]
            },
            awards: {
              oscars: 1,
              golden_globes: 1,
              cannes_awards: 1
            },
            trivia: [
              "Won Palme d'Or",
              "Revived John Travolta career",
              "Non-linear narrative structure"
            ],
            production: {
              studio: "Miramax",
              director: "Quentin Tarantino",
              budget: 8_000_000,
              revenue: 213_900_000
            },
            released_at: Time.parse("1994-10-14"),
            updated_at: Time.current
          }
        }
      end
    end
  end
end
