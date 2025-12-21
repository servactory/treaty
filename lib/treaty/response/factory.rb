# frozen_string_literal: true

module Treaty
  module Response
    # Factory for creating response definitions.
    #
    # Inherits from Attribute::FactoryBase to eliminate code duplication.
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
    class Factory < Treaty::Attribute::FactoryBase
      attr_reader :status

      def initialize(status)
        super()
        @status = status
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

      protected

      # Returns I18n key for invalid entity class error
      #
      # @return [String] I18n key
      def invalid_entity_i18n_key
        "treaty.response.factory.invalid_entity_class"
      end
    end
  end
end
