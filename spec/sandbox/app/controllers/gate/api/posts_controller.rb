# frozen_string_literal: true

module Gate
  module API
    class PostsController < Gate::API::BaseController
      treaty :index do
        provide :posts, from: :load_posts

        # Examples:
        provide :meta_string, from: "String"
        provide :meta_integer, from: 1
        provide :meta_proc, from: -> {}
      end

      treaty :create do
        provide :post, from: :load_post
      end

      # Below are examples of incorrect usage.

      treaty :invalid_class

      private

      def load_posts
        ["Post"]
      end

      def load_post
        "Post"
      end
    end
  end
end
