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

        # Create orchestrator for both DIRECT and ADAPTER strategies
        # Orchestrator filters data by attributes and performs transformation
        orchestrator_class = Class.new(Treaty::Attribute::Validation::Orchestrator::Base) do
          define_method(:collection_of_attributes) do
            @version_factory.response_factory.collection_of_attributes
          end
        end

        orchestrator_class.validate!(
          version_factory: @version_factory,
          data: @response_data
        )
      end

      def adapter_strategy?
        !@version_factory.strategy_instance.direct?
      end

      def response_attributes_exist?
        return false if @version_factory.response_factory&.collection_of_attributes&.empty?

        @version_factory.response_factory.collection_of_attributes.exists?
      end
    end
  end
end
