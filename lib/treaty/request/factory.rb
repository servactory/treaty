# frozen_string_literal: true

module Treaty
  module Request
    # Factory for creating request definitions.
    #
    # Supports two modes:
    # 1. Block mode: Creates an anonymous Request::Entity class with the block
    # 2. Entity mode: Uses a provided Entity class directly
    #
    # ## Block Mode
    #
    # ```ruby
    # request do
    #   object :post do
    #     string :title
    #   end
    # end
    # ```
    #
    # ## Entity Mode
    #
    # ```ruby
    # request PostRequestEntity
    # ```
    class Factory
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
        return Treaty::Attribute::Collection.new if @entity_class.nil?

        @entity_class.collection_of_attributes
      end

      # Handles DSL methods for defining attributes
      #
      # This allows the factory to be used with method_missing
      # for backwards compatibility with direct method calls.
      # Creates an anonymous Request::Entity class on first use.
      def method_missing(type, *helpers, **options, &block)
        # If no entity class yet, create one
        @entity_class ||= Class.new(Entity)

        # Call the method on the entity class
        @entity_class.public_send(type, *helpers, **options, &block)
      end

      def respond_to_missing?(name, *)
        super
      end

      private

      # Validates that the provided entity_class is a valid Treaty::Entity subclass
      #
      # @param entity_class [Class] Entity class to validate
      # @raise [Treaty::Exceptions::Validation] if entity_class is not a valid Treaty::Entity subclass
      def validate_entity_class!(entity_class)
        return if entity_class.is_a?(Class) && entity_class < Treaty::Entity

        raise Treaty::Exceptions::Validation,
              I18n.t("treaty.request.factory.invalid_entity_class",
                     type: entity_class.class,
                     value: entity_class)
      end
    end
  end
end
