# frozen_string_literal: true

module Languages
  module Stable
    class IndexService < ApplicationService::Base
      input :params, type: Hash, required: false, default: {}

      output :data, type: Hash

      private

      def call # rubocop:disable Metrics/MethodLength
        outputs.data = {
          features: [
            {
              id: SecureRandom.uuid,
              name: "Blocks",
              category: "syntax",
              paradigm: "functional",
              description: "Anonymous code blocks",
              gems: %w[rspec sinatra],
              statistics: {
                usage_count: 1500,
                popularity_score: 95
              },
              introduced_at: Time.parse("2004-12-25")
            },
            {
              id: SecureRandom.uuid,
              name: "Lambdas",
              category: "functional",
              paradigm: "functional",
              description: "Anonymous functions with strict arity",
              gems: %w[dry-rb],
              statistics: {
                usage_count: 800,
                popularity_score: 85
              },
              introduced_at: Time.parse("2004-12-25")
            }
          ],
          meta: {
            count: 2,
            page: 1,
            limit: 20
          }
        }
      end
    end
  end
end
