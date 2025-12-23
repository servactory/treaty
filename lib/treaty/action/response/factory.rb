# frozen_string_literal: true

module Treaty
  module Action
    module Response
      # Factory for creating response attribute collections.
      #
      # ## Purpose
      #
      # Captures response attribute definitions from treaty DSL and provides
      # access to the resulting attribute collection. Supports both inline
      # block syntax and Entity class references.
      #
      # ## Difference from Request::Factory
      #
      # Response::Factory stores HTTP status code along with attributes.
      # This allows treaty to validate responses against expected status.
      #
      # ## Usage
      #
      # Created internally by:
      # - Versions::Factory (when `response STATUS do ... end` is called)
      #
      # Consumed by:
      # - Response::Validator (to validate service output)
      # - Info::Builder (to build response schema information)
      # - Versions::Execution::Base (to set response status)
      #
      # ## Definition Modes
      #
      # ### Inline Block Mode
      #
      #   response 201 do
      #     object :post do
      #       string :id
      #       string :title
      #     end
      #   end
      #
      # ### Entity Class Mode
      #
      #   response 201, Posts::Create::ResponseEntity
      #
      # ## Example
      #
      #   factory = Response::Factory.new(201)
      #   factory.status  # => 201
      #   factory.object :post do
      #     factory.string :id
      #   end
      #   factory.collection_of_attributes  # => Collection with post attribute
      class Factory
        # @return [Integer] HTTP status code for this response
        attr_reader :status

        # Creates new response factory with HTTP status
        #
        # @param status [Integer] HTTP status code (200, 201, 404, etc.)
        def initialize(status)
          @status = status
        end

        # Registers an Entity class for response schema
        #
        # Use this to reference a pre-defined Entity class instead of
        # inline attribute definitions.
        #
        # @param entity_class [Class] Must be Treaty::Entity::Base subclass
        # @raise [Treaty::Exceptions::Validation] If entity_class is invalid
        # @return [void]
        def use_entity(entity_class)
          validate_entity_class!(entity_class)
          @entity_class = entity_class
        end

        # Returns the collection of defined attributes
        #
        # @return [Treaty::Entity::Attribute::Collection] Attribute collection
        def collection_of_attributes
          return Treaty::Entity::Attribute::Collection.new if @entity_class.nil?

          @entity_class.collection_of_attributes
        end

        # Forwards DSL method calls to internal Entity class
        #
        # Creates an anonymous Entity class on first call, then forwards
        # all DSL methods (string, integer, object, etc.) to it.
        #
        # @param type [Symbol] Attribute type (method name)
        # @param helpers [Array] Helper symbols and arguments
        # @param options [Hash] Attribute options
        # @param block [Proc] Block for nested attributes
        # @return [void]
        def method_missing(type, *helpers, **options, &block)
          @entity_class ||= Class.new(Entity)

          @entity_class.public_send(type, *helpers, **options, &block)
        end

        # Checks if method should be handled by method_missing
        #
        # @param name [Symbol] Method name
        # @return [Boolean]
        def respond_to_missing?(name, *)
          super
        end

        private

        # Validates that entity_class is a Treaty::Entity::Base subclass
        #
        # @param entity_class [Class] Class to validate
        # @raise [Treaty::Exceptions::Validation] If validation fails
        # @return [void]
        def validate_entity_class!(entity_class)
          return if entity_class.is_a?(Class) && entity_class < Treaty::Entity::Base

          raise Treaty::Exceptions::Validation,
                I18n.t(
                  "treaty.response.factory.invalid_entity_class",
                  type: entity_class.class,
                  value: entity_class
                )
        end
      end
    end
  end
end
