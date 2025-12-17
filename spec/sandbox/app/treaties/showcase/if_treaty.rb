# frozen_string_literal: true

module Showcase
  class IfTreaty < ApplicationTreaty
    version 1 do
      summary "Showing if option in request"

      request do
        object :showcase do
          boolean :flag, :optional
          string :example1, :optional
          string :example2, :optional, if: ->(showcase:) { showcase[:flag] == true }
        end
      end

      response 200 do
        object :showcase do
          boolean :flag
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
      summary "Showing if option in response"

      request do
        object :showcase do
          boolean :flag, :optional
          string :example1, :optional
          string :example2, :optional
        end
      end

      response 200 do
        object :showcase do
          boolean :flag
          string :example1
          string :example2, if: ->(showcase:) { showcase[:flag] == true }
        end
      end

      delegate_to(lambda do |params:|
        # NOTE: To avoid using the service for any reason,
        #       use Proc to work with params locally.
        params
      end)
    end

    version 3 do
      summary "Showing if option on nested objects"

      request do
        object :showcase do
          boolean :flag, :optional
          string :example1, :optional
          object :nested, :optional, if: ->(showcase:) { showcase[:flag] == true } do
            string :value, :optional
          end
        end
      end

      response 200 do
        object :showcase do
          boolean :flag
          string :example1
          object :nested do
            string :value
          end
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
