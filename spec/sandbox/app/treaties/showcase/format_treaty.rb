# frozen_string_literal: true

module Showcase
  class FormatTreaty < ApplicationTreaty
    version 1 do
      summary "Showing format option with basic formats in request"

      request do
        object :showcase do
          string :example1, :optional, format: :uuid
          string :example2, :optional, format: :email
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
      summary "Showing format option with date/time formats in request"

      request do
        object :showcase do
          string :example1, :optional, format: :date
          string :example2, :optional, format: :datetime
          string :example3, :optional, format: :time
        end
      end

      response 200 do
        object :showcase do
          string :example1
          string :example2
          string :example3
        end
      end

      delegate_to(lambda do |params:|
        # NOTE: To avoid using the service for any reason,
        #       use Proc to work with params locally.
        params
      end)
    end

    version 3 do
      summary "Showing format option with other formats in request"

      request do
        object :showcase do
          string :example1, :optional, format: :password
          string :example2, :optional, format: :duration
          string :example3, :optional, format: :boolean
        end
      end

      response 200 do
        object :showcase do
          string :example1
          string :example2
          string :example3
        end
      end

      delegate_to(lambda do |params:|
        # NOTE: To avoid using the service for any reason,
        #       use Proc to work with params locally.
        params
      end)
    end

    version 4 do
      summary "Showing format option with advanced mode in request"

      request do
        object :showcase do
          string :example1, :optional, format: { is: :uuid, message: nil }
          string :example2, :optional, format: { is: :email, message: nil }
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

    version 5 do
      summary "Showing custom message with format option"

      request do
        object :showcase do
          string :example1, :optional, format: {
            is: :email,
            message: "Invalid email format"
          }
          string :example2, :optional, format: {
            is: :uuid,
            message: ->(attribute:, value:, **) { "#{attribute} is not a valid UUID (got: #{value})" }
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
