# frozen_string_literal: true

module Showcase
  class ComputedTreaty < ApplicationTreaty # rubocop:disable Metrics/ClassLength
    version 1 do
      summary "Showing computed option in request"

      request do
        object :showcase do
          string :first_name, :optional
          string :last_name, :optional
          string :full_name, :optional, computed: (lambda do |**attributes|
            first = attributes.dig(:showcase, :first_name)
            last = attributes.dig(:showcase, :last_name)
            [first, last].compact.join(" ")
          end)
        end
      end

      response 200 do
        object :showcase do
          string :first_name
          string :last_name
          string :full_name
        end
      end

      delegate_to(lambda do |params:|
        # NOTE: To avoid using the service for any reason,
        #       use Proc to work with params locally.
        params
      end)
    end

    version 2 do
      summary "Showing computed option in response"

      request do
        object :showcase do
          string :first_name, :optional
          string :last_name, :optional
        end
      end

      response 200 do
        object :showcase do
          string :first_name
          string :last_name
          string :full_name, computed: (lambda do |**attributes|
            first = attributes.dig(:showcase, :first_name)
            last = attributes.dig(:showcase, :last_name)
            [first, last].compact.join(" ")
          end)
        end
      end

      delegate_to(lambda do |params:|
        # NOTE: To avoid using the service for any reason,
        #       use Proc to work with params locally.
        params
      end)
    end

    version 3 do
      summary "Showing computed option with advanced mode in request"

      request do
        object :showcase do
          string :first_name, :optional
          string :last_name, :optional
          string :full_name, :optional, computed: {
            is: (lambda do |**attributes|
              first = attributes.dig(:showcase, :first_name)
              last = attributes.dig(:showcase, :last_name)
              [first, last].compact.join(" ")
            end),
            message: nil
          }
        end
      end

      response 200 do
        object :showcase do
          string :first_name
          string :last_name
          string :full_name
        end
      end

      delegate_to(lambda do |params:|
        # NOTE: To avoid using the service for any reason,
        #       use Proc to work with params locally.
        params
      end)
    end

    version 4 do
      summary "Showing custom message with computed option"

      request do
        object :showcase do
          string :first_name, :optional
          string :last_name, :optional
          string :full_name, :optional, computed: {
            is: (lambda do |**attributes|
              first = attributes.dig(:showcase, :first_name)
              last = attributes.dig(:showcase, :last_name)
              [first, last].compact.join(" ")
            end),
            message: "Failed to compute full name"
          }
          string :initials, :optional, computed: {
            is: (lambda do |**attributes|
              first = attributes.dig(:showcase, :first_name)
              last = attributes.dig(:showcase, :last_name)
              "#{first&.chars&.first}#{last&.chars&.first}".upcase
            end),
            message: ->(attribute:, **) { "#{attribute} computation failed" }
          }
        end
      end

      response 200 do
        object :showcase do
          string :first_name
          string :last_name
          string :full_name
          string :initials
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
