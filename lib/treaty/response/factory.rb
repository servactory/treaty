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

      # Creates an anonymous Entity class with required: false as default.
      # This matches the documented behavior for response blocks.
      #
      # @return [Class] Anonymous Entity class
      def create_anonymous_entity_class
        attribute_creator = response_attribute_creator
        Class.new(Treaty::Entity) do
          define_singleton_method(:create_attribute, &attribute_creator)
        end
      end

      # Returns a proc that creates attributes with required: false default
      #
      # @return [Proc] Attribute creator proc
      def response_attribute_creator
        proc do |name, type, *helpers, nesting_level:, **options, &block|
          Treaty::Entity::Attribute::Attribute.new(
            name, type, *helpers, nesting_level:, default_required: false, **options, &block
          )
        end
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
