# frozen_string_literal: true

module Treaty
  module Response
    # Factory for creating response definitions.
    #
    # Supports two modes:
    # 1. Block mode: Creates an anonymous Treaty::Entity class with the block
    # 2. Entity mode: Uses a provided Entity class directly
    #
    # ## Block Mode
    #
    # ```ruby
    # response 200 do
    #   object :post do
    #     string :id
    #   end
    # end
    # ```
    #
    # ## Entity Mode
    #
    # ```ruby
    # response 200, PostResponseEntity
    # ```
    class Factory
      attr_reader :status, :entity_class

      def initialize(status)
        @status = status
      end

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

      # Returns info about response attributes with preset applied
      #
      # Reads preset_options from Validator class method (single source of truth)
      #
      # @return [Hash] Info structure with attributes
      def info
        return { attributes: {} } if @entity_class.nil?

        result = @entity_class.info(preset: Treaty::Response::Validator.preset_options)
        { attributes: result.attributes }
      end

      # Handles DSL methods for defining attributes
      #
      # This allows the factory to be used with method_missing
      # for backwards compatibility with direct method calls.
      # Creates an anonymous Treaty::Entity class on first use.
      def method_missing(type, *helpers, **options, &block)
        # If no entity class yet, create an anonymous Treaty::Entity with required: false default
        @entity_class ||= create_anonymous_entity_class

        # Call the method on the entity class
        @entity_class.public_send(type, *helpers, **options, &block)
      end

      def respond_to_missing?(name, *)
        super
      end

      private

      # Creates an anonymous Entity class for response definitions.
      # Entity attributes are required by default (required: true).
      # Response::Validator uses .preset(required: false) to make all fields optional.
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
                "treaty.response.factory.invalid_entity_class",
                type: entity_class.class,
                value: entity_class
              )
      end
    end
  end
end
