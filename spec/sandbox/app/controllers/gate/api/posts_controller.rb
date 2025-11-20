# frozen_string_literal: true

module Gate
  module API
    class PostsController < Gate::API::BaseController
      treaty :index do
        provide :posts, from: :load_posts

        # Or
        # provide :posts, from: -> { load_posts }
        # provide :posts, from: -> { Post.all }
        # provide :some_value, from: "Text"
        # provide :some_value, from: -> { "Text" }

        # Forbidden (because it will be loaded with the application):
        # provide :posts, from: load_posts
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
