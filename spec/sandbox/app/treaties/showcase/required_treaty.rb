# frozen_string_literal: true

module Showcase
  class RequiredTreaty < ApplicationTreaty
    version 1 do
      summary "Showing required option with helper mode in request"

      request do
        object :showcase do
          string :example1, :required
          string :example2, :optional
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
      summary "Showing required option with simple mode in request"

      request do
        object :showcase do
          string :example1, required: true
          string :example2, required: false
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
      summary "Showing required option with advanced mode in request"

      request do
        object :showcase do
          string :example1, required: { is: true, message: nil }
          string :example2, required: { is: false, message: nil }
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

    version 4 do
      summary "Showing custom message with required option"

      request do
        object :showcase do
          string :example1, required: { is: true, message: "Example1 field is required" }
          string :example2, required: {
            is: true,
            message: ->(attribute:, **) { "#{attribute} must be provided" }
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
