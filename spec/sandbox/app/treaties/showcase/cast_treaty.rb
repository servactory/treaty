# frozen_string_literal: true

module Showcase
  class CastTreaty < ApplicationTreaty
    version 1 do
      summary "Showing cast option with string to datetime in request"

      request do
        object :showcase do
          string :example1, :optional, cast: :datetime
          string :example2, :optional, cast: :date
          string :example3, :optional, cast: :time
        end
      end

      response 200 do
        object :showcase do
          datetime :example1
          date :example2
          time :example3
        end
      end

      delegate_to(lambda do |params:|
        # NOTE: To avoid using the service for any reason,
        #       use Proc to work with params locally.
        params
      end)
    end

    version 2 do
      summary "Showing cast option with datetime to string in response"

      request do
        object :showcase do
          datetime :example1, :optional
          date :example2, :optional
          time :example3, :optional
        end
      end

      response 200 do
        object :showcase do
          datetime :example1, cast: :string
          date :example2, cast: :string
          time :example3, cast: :string
        end
      end

      delegate_to(lambda do |params:|
        # NOTE: To avoid using the service for any reason,
        #       use Proc to work with params locally.
        params
      end)
    end

    version 3 do
      summary "Showing cast option with integer conversions"

      request do
        object :showcase do
          integer :example1, :optional, cast: :boolean
          integer :example2, :optional, cast: :string
          string :example3, :optional, cast: :integer
        end
      end

      response 200 do
        object :showcase do
          boolean :example1
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

    version 4 do
      summary "Showing cast option with advanced mode in request"

      request do
        object :showcase do
          string :example1, :optional, cast: { to: :datetime, message: nil }
          string :example2, :optional, cast: { to: :integer, message: nil }
        end
      end

      response 200 do
        object :showcase do
          datetime :example1
          integer :example2
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
