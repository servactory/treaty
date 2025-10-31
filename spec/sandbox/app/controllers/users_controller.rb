# frozen_string_literal: true

class UsersController < ApplicationController
  treaty :index

  treaty :create

  # Equivalent to:
  # def create
  #   treaty = Users::CreateTreaty.call!(context: self, params:)
  #
  #   render json: treaty.data, status: treaty.status
  # end
end
