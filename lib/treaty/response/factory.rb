# frozen_string_literal: true

module Treaty
  module Response
    # Factory for creating response definitions.
    #
    # Supports two modes:
    # 1. Block mode: Creates an anonymous Response::Entity class with the block
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
      attr_reader :status

      def initialize(status)
        @status = status
      end

      # Uses a provided Entity class
      #
      # @param entity_class [Class] Entity class to use
      # @return [void]
      def use_entity(entity_class)
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
      # Creates an anonymous Response::Entity class on first use.
      def method_missing(type, *helpers, **options, &block)
        # If no entity class yet, create one
        @entity_class ||= Class.new(Entity)

        # Call the method on the entity class
        @entity_class.public_send(type, *helpers, **options, &block)
      end

      def respond_to_missing?(name, *)
        super
      end
    end
  end
end
