# frozen_string_literal: true

module Showcase
  class DefaultTreaty < ApplicationTreaty
    version 1 do
      summary "Showing default value in request"

      request do
        object :showcase do
          string :example1, :optional, default: "Example 1"
          string :example2, :optional, default: { is: "Example 2" }
          string :example3, :optional, default: -> { "Example 3" }
          string :example4, :optional, default: { is: -> { "Example 4" } }
        end
      end

      response 200 do
        object :showcase do
          string :example1
          string :example2
          string :example3
          string :example4
        end
      end

      delegate_to(lambda do |params:|
        # NOTE: To avoid using the service for any reason,
        #       use Proc to work with params locally.
        params
      end)
    end

    version 2 do
      summary "Showing default value in response"

      request do
        object :showcase do
          string :example1, :optional
          string :example2, :optional
          string :example3, :optional
          string :example4, :optional
        end
      end

      response 200 do
        object :showcase do
          string :example1, default: "Example 1"
          string :example2, default: { is: "Example 2" }
          string :example3, default: -> { "Example 3" }
          string :example4, default: { is: -> { "Example 4" } }
        end
      end

      delegate_to(lambda do |params:|
        # NOTE: To avoid using the service for any reason,
        #       use Proc to work with params locally.
        params
      end)
    end

    version 3 do
      summary "Showing custom message with required option"

      request do
        object :showcase do
          string :example1, required: { is: true, message: "Example1 is required" }
          string :example2, required: {
            is: true,
            message: ->(attribute:, **) { "#{attribute} cannot be blank" }
          }
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
  end
end
