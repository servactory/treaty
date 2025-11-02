# frozen_string_literal: true

module Gate
  module API
    class UsersController < Gate::API::BaseController
      treaty :index

      treaty :create

      treaty :invalid_class

      treaty :invalid_strategy
    end
  end
end
