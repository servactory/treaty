# frozen_string_literal: true

module Showcase
  class TransformTreaty < ApplicationTreaty
    version 1 do
      summary "Showing transform option in request"

      request do
        object :showcase do
          string :example1, :optional, transform: ->(value:) { value&.upcase }
          string :example2, :optional, transform: ->(value:) { value&.strip }
          integer :example3, :optional, transform: ->(value:) { value.to_i * 100 }
        end
      end

      response 200 do
        object :showcase do
          string :example1
          string :example2
          integer :example3
        end
      end

      delegate_to(lambda do |params:|
        # NOTE: To avoid using the service for any reason,
        #       use Proc to work with params locally.
        params
      end)
    end

    version 2 do
      summary "Showing transform option in response"

      request do
        object :showcase do
          string :example1, :optional
          string :example2, :optional
          integer :example3, :optional
        end
      end

      response 200 do
        object :showcase do
          string :example1, transform: ->(value:) { value&.upcase }
          string :example2, transform: ->(value:) { value&.strip }
          integer :example3, transform: ->(value:) { value.to_i * 100 }
        end
      end

      delegate_to(lambda do |params:|
        # NOTE: To avoid using the service for any reason,
        #       use Proc to work with params locally.
        params
      end)
    end

    version 3 do
      summary "Showing transform option with advanced mode in request"

      request do
        object :showcase do
          string :example1, :optional, transform: { is: ->(value:) { value&.upcase }, message: nil }
          string :example2, :optional, transform: { is: ->(value:) { value&.strip }, message: nil }
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
