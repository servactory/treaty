# frozen_string_literal: true

module Posts
  module Stable
    class CreateService < ApplicationService::Base
      input :inventory, type: Treaty::Executor::Inventory, required: false
      input :params, type: Hash

      output :data, type: Hash

      private

      def call # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        post_data = inputs.params.fetch(:post, {})
        author_data = post_data.fetch(:author, {})

        outputs.data = {
          post: {
            id: SecureRandom.uuid,
            title: post_data[:title] || "New Post",
            summary: post_data[:summary] || "Summary",
            description: post_data[:description] || "Description",
            content: post_data[:content] || "Content",
            published: post_data[:published],
            featured: post_data[:featured],
            published_at: post_data[:published_at] || Time.current,
            tags: post_data.fetch(:tags, []),
            author: author_data,
            slug: post_data[:slug],
            word_count: post_data[:word_count],
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
