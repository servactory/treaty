# frozen_string_literal: true

module Treaty
  module Response
    # Validator for response data
    class Validator
      class << self
        # Validates response data against the response definition
        #
        # @param response_data [Hash] Response data to validate
        # @param version_factory [Versions::Factory] Version factory with response definition
        # @return [Hash] Validated and transformed response data
        def validate!(version_factory:, response_data: {})
          new(version_factory:, response_data:).validate!
        end
      end

      def initialize(version_factory:, response_data: {})
        @version_factory = version_factory
        @response_data = response_data
      end

      def validate!
        validate_response_attributes!
      end

      private

      def validate_response_attributes!
        return @response_data unless response_attributes_exist?

        # Use Entity.preset(required: false).call! for validation
        # Response uses required: false by default to make all fields optional
        entity_class = @version_factory.response_factory.entity_class
        result = entity_class.preset(required: false).call!(@response_data)
        result.data
      end

      def response_attributes_exist?
        return false if @version_factory.response_factory&.collection_of_attributes&.empty?

        @version_factory.response_factory.collection_of_attributes.exists?
      end
    end
  end
end
