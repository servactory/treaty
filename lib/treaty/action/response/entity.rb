# frozen_string_literal: true

module Treaty
  module Action
    module Response
      # Internal entity class for response attribute definitions.
      #
      # ## Purpose
      #
      # Provides DSL interface for defining response attributes when using
      # inline block syntax in treaty definitions. Serves as the anonymous
      # class base when `response STATUS do ... end` is used.
      #
      # ## Usage
      #
      # Created internally by:
      # - Response::Factory (when using inline DSL blocks)
      #
      # ## DSL Interface
      #
      # Includes Treaty::Entity::Attribute::DSL which provides:
      # - Type methods: string, integer, boolean, date, time, datetime
      # - Structure methods: object, array
      # - Helper support: :required, :optional
      #
      # ## Difference from Treaty::Entity::Base
      #
      # While Treaty::Entity::Base creates standalone entity classes,
      # Response::Entity creates Response-specific attributes with:
      # - Optional by default behavior
      # - Response::Attribute::Attribute instances
      #
      # ## Example
      #
      #   # When you write:
      #   version 1 do
      #     response 201 do
      #       object :post do
      #         string :id
      #         string :title
      #       end
      #     end
      #   end
      #
      #   # Factory creates: Class.new(Response::Entity)
      #   # and calls string, object etc. on it
      class Entity
        include Treaty::Entity::Attribute::DSL

        class << self
          private

          # Creates response-specific attribute instances
          #
          # Called by DSL methods (string, integer, etc.) to create
          # Response::Attribute::Attribute instead of generic attributes.
          #
          # @param name [Symbol] Attribute name
          # @param type [Symbol] Attribute type
          # @param helpers [Array<Symbol>] Helper symbols (:required, :optional)
          # @param nesting_level [Integer] Current nesting depth
          # @param options [Hash] Attribute options
          # @param block [Proc] Block for nested attributes
          # @return [Response::Attribute::Attribute] Created attribute
          def create_attribute(name, type, *helpers, nesting_level:, **options, &block)
            Attribute::Attribute.new(
              name,
              type,
              *helpers,
              nesting_level:,
              **options,
              &block
            )
          end
        end
      end
    end
  end
end
