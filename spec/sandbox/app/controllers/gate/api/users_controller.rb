# frozen_string_literal: true

module Gate
  module API
    class UsersController < Gate::API::BaseController
      treaty :index

      treaty :create

      treaty :invalid_class

      # Equivalent to:
      # def create
      #   treaty = Users::CreateTreaty.call!(controller: self, params:)
      #
      #   render json: treaty.data, status: treaty.status
      # end
    end
  end
end
