# frozen_string_literal: true

module Posts
  module Stable
    class CreateService < ApplicationService::Base
      input :params, type: Hash

      output :data, type: Hash

      private

      def call # rubocop:disable Metrics/MethodLength
        post_data = inputs.params.fetch(:post, {})

        outputs.data = {
          post: {
            id: SecureRandom.uuid,
            title: post_data[:title] || "New Post",
            summary: post_data[:summary] || "Summary",
            description: post_data[:description] || "Description",
            content: post_data[:content] || "Content",
            tags: post_data.fetch(:tags, []),
            author: post_data.fetch(:author, {}),
            rating: 0,
            views: 0,
            created_at: Time.current,
            updated_at: Time.current
          }
        }
      end
    end
  end
end
