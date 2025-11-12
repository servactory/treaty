# frozen_string_literal: true

module Movies
  module Stable
    class IndexService < ApplicationService::Base
      input :params, type: Hash, required: false, default: {}

      output :data, type: Hash

      private

      def call # rubocop:disable Metrics/MethodLength
        outputs.data = {
          movies: [
            {
              id: SecureRandom.uuid,
              title: "Pulp Fiction",
              year: 1994,
              genre: "crime",
              runtime: 154,
              plot: "Interconnected criminal stories",
              rating: 9,
              cast: [
                {
                  actor: "John Travolta",
                  character: "Vincent Vega",
                  lead_role: true
                },
                {
                  actor: "Uma Thurman",
                  character: "Mia Wallace",
                  lead_role: true
                }
              ],
              awards: {
                oscars: 1,
                golden_globes: 1,
                baftas: 0
              },
              released_at: Time.parse("1994-10-14")
            },
            {
              id: SecureRandom.uuid,
              title: "Kill Bill Vol. 1",
              year: 2003,
              genre: "action",
              runtime: 111,
              plot: "Bride seeks revenge",
              rating: 8,
              cast: [
                {
                  actor: "Uma Thurman",
                  character: "The Bride",
                  lead_role: true
                }
              ],
              awards: {
                oscars: 0,
                golden_globes: 0,
                baftas: 0
              },
              released_at: Time.parse("2003-10-10")
            }
          ],
          meta: {
            count: 2,
            page: 1,
            total_pages: 1,
            limit: 15
          }
        }
      end
    end
  end
end
