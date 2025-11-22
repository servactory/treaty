# frozen_string_literal: true

module Posts
  module Stable
    class IndexService < ApplicationService::Base
      input :inventory, type: Treaty::Executor::Inventory, required: false
      input :params, type: Hash, required: false, default: {}

      output :data, type: Hash

      private

      def call # rubocop:disable Metrics/MethodLength
        outputs.data = {
          posts: [
            {
              id: SecureRandom.uuid,
              title: "Title 1",
              summary: "Summary 1",
              description: "Description 1",
              content: "...",
              created_at: Time.current
            }
          ],
          meta: {
            count: 1,
            page: 1,
            limit: 10
          }
        }
      end
    end
  end
end
