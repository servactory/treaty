# frozen_string_literal: true

module Treaty
  module Attribute
    # Base class for Request::Factory and Response::Factory.
    #
    # ## Purpose
    #
    # Eliminates code duplication between Request::Factory and Response::Factory.
    # Both factories share 95% identical code for creating and managing entity classes.
    #
    # ## Responsibilities
    #
    # 1. **Entity Management** - Creates and manages anonymous Treaty::Entity classes
    # 2. **DSL Forwarding** - Forwards DSL methods to entity class via method_missing
    # 3. **Attribute Collection** - Provides access to collection of attributes
    # 4. **Validation** - Validates that entity classes are Treaty::Entity subclasses
    #
    # ## Usage
    #
    # Subclasses must implement:
    # - `info` - Returns info structure with attributes (uses different presets)
    # - `invalid_entity_i18n_key` - I18n key for validation error messages
    #
    # Subclasses may override:
    # - `initialize` - For additional initialization (e.g., status for Response)
    #
    # ## Architecture
    #
    # Both Request and Response factories create Treaty::Entity subclasses.
    # The difference is in how they apply presets during validation:
    # - Request::Validator uses empty preset (Entity defaults apply)
    # - Response::Validator uses `required: false` preset (all optional)
    class FactoryBase
      attr_reader :entity_class

      # Uses a provided Entity class
      #
      # @param entity_class [Class] Entity class to use
      # @return [void]
      # @raise [Treaty::Exceptions::Validation] if entity_class is not a valid Treaty::Entity subclass
      def use_entity(entity_class)
        validate_entity_class!(entity_class)
        @entity_class = entity_class
      end

      # Returns collection of attributes from the entity class
      #
      # @return [Collection] Collection of attributes
      def collection_of_attributes
        return Treaty::Entity::Attribute::Collection.new if @entity_class.nil?

        @entity_class.collection_of_attributes
      end

      # Handles DSL methods for defining attributes
      #
      # This allows the factory to be used with method_missing
      # for backwards compatibility with direct method calls.
      # Creates an anonymous Treaty::Entity class on first use.
      def method_missing(type, *helpers, **options, &block)
        @entity_class ||= create_anonymous_entity_class

        @entity_class.public_send(type, *helpers, **options, &block)
      end

      def respond_to_missing?(name, *)
        super
      end

      protected

      # Creates an anonymous Entity class
      # Subclasses can override if different entity class needed
      #
      # @return [Class] Anonymous Entity class
      def create_anonymous_entity_class
        Class.new(Treaty::Entity)
      end

      # Validates that the provided entity_class is a valid Treaty::Entity subclass
      #
      # @param entity_class [Class] Entity class to validate
      # @raise [Treaty::Exceptions::Validation] if entity_class is not a valid Treaty::Entity subclass
      def validate_entity_class!(entity_class)
        return if entity_class.is_a?(Class) && entity_class < Treaty::Entity

        raise Treaty::Exceptions::Validation,
              I18n.t(
                invalid_entity_i18n_key,
                type: entity_class.class,
                value: entity_class
              )
      end

      # Returns I18n key for invalid entity class error
      # Must be implemented by subclasses
      #
      # @raise [NotImplementedError] If not implemented
      # @return [String] I18n key
      def invalid_entity_i18n_key
        raise NotImplementedError, "#{self.class} must implement #invalid_entity_i18n_key"
      end
    end
  end
end
