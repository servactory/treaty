# frozen_string_literal: true

module Showcase
  class AsTreaty < ApplicationTreaty
    version 1 do
      summary "Showing as option in request"

      request do
        object :showcase do
          string :user_name, :optional, as: :name
          string :user_email, :optional, as: :email
        end
      end

      response 200 do
        object :showcase do
          string :name
          string :email
        end
      end

      delegate_to(lambda do |params:|
        # NOTE: To avoid using the service for any reason,
        #       use Proc to work with params locally.
        params
      end)
    end

    version 2 do
      summary "Showing as option in response"

      request do
        object :showcase do
          string :name, :optional
          string :email, :optional
        end
      end

      response 200 do
        object :showcase do
          string :name, as: :user_name
          string :email, as: :user_email
        end
      end

      delegate_to(lambda do |params:|
        # NOTE: To avoid using the service for any reason,
        #       use Proc to work with params locally.
        params
      end)
    end
  end
end
