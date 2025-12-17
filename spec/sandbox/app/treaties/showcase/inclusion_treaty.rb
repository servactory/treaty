# frozen_string_literal: true

module Showcase
  class InclusionTreaty < ApplicationTreaty
    version 1 do
      summary "Showing inclusion option with simple mode in request"

      request do
        object :showcase do
          string :example1, :optional, in: %w[option1 option2 option3]
          string :example2, :optional, in: %w[alpha beta gamma]
        end
      end

      response 200 do
        object :showcase do
          string :example1
          string :example2
        end
      end

      delegate_to(lambda do |params:|
        # NOTE: To avoid using the service for any reason,
        #       use Proc to work with params locally.
        params
      end)
    end

    version 2 do
      summary "Showing inclusion option with advanced mode in request"

      request do
        object :showcase do
          string :example1, :optional, inclusion: { in: %w[option1 option2 option3], message: nil }
          string :example2, :optional, inclusion: { in: %w[alpha beta gamma], message: nil }
        end
      end

      response 200 do
        object :showcase do
          string :example1
          string :example2
        end
      end

      delegate_to(lambda do |params:|
        # NOTE: To avoid using the service for any reason,
        #       use Proc to work with params locally.
        params
      end)
    end

    version 3 do
      summary "Showing inclusion option in response"

      request do
        object :showcase do
          string :example1, :optional
          string :example2, :optional
        end
      end

      response 200 do
        object :showcase do
          string :example1, in: %w[option1 option2 option3]
          string :example2, in: %w[alpha beta gamma]
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
