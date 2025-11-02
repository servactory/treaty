# frozen_string_literal: true

module Gate
  module API
    class UsersController < Gate::API::BaseController
      treaty :index

      treaty :create

      # Below are examples of incorrect usage.

      treaty :invalid_class

      treaty :invalid_strategy

      treaty :invalid_version_method
    end
  end
end
