# frozen_string_literal: true

module Gate
  module API
    class PostsController < Gate::API::BaseController
      treaty :index

      treaty :create

      # Below are examples of incorrect usage.

      treaty :invalid_class
    end
  end
end
