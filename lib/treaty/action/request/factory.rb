# frozen_string_literal: true

module Treaty
  module Action
    module Request
      # Factory for creating request attribute collections.
      #
      # ## Purpose
      #
      # Captures request attribute definitions from treaty DSL and provides
      # access to the resulting attribute collection. Supports both inline
      # block syntax and Entity class references.
      #
      # ## Usage
      #
      # Created internally by:
      # - Versions::Factory (when `request do ... end` is called)
      #
      # Consumed by:
      # - Request::Validator (to validate incoming params)
      # - Info::Builder (to build request schema information)
      #
      # ## Definition Modes
      #
      # ### Inline Block Mode
      #
      #   request do
      #     object :post do
      #       string :title, :required
      #     end
      #   end
      #
      # ### Entity Class Mode
      #
      #   request Posts::Create::RequestEntity
      #
      # ## Implementation
      #
      # Uses method_missing to forward DSL calls to a dynamically created
      # Entity class. The Entity class collects all attribute definitions.
      #
      # ## Example
      #
      #   factory = Request::Factory.new
      #   factory.object :post do
      #     factory.string :title, :required
      #   end
      #   factory.collection_of_attributes  # => Collection with post attribute
      class Factory
        # Registers an Entity class for request schema
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
                  "treaty.request.factory.invalid_entity_class",
                  type: entity_class.class,
                  value: entity_class
                )
        end
      end
    end
  end
end
