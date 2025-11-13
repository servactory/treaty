# frozen_string_literal: true

module Treaty
  module Request
    # Validator for request data
    class Validator
      class << self
        # Validates request parameters against the request definition
        #
        # @param params [Hash] Request parameters to validate
        # @param version_factory [Versions::Factory] Version factory with request definition
        # @return [Hash] Validated and transformed parameters
        def validate!(params:, version_factory:)
          new(params:, version_factory:).validate!
        end
      end

      def initialize(params:, version_factory:)
        @params = params
        @version_factory = version_factory
      end

      def validate!
        validate_request_attributes!
      end

      private

      def request_data
        @request_data ||= begin
          @params.to_unsafe_h
        rescue NoMethodError
          @params
        end
      end

      def validate_request_attributes! # rubocop:disable Metrics/MethodLength
        return request_data unless adapter_strategy?
        return request_data unless request_attributes_exist?

        # For adapter strategy with attributes defined:
        orchestrator_class = Class.new(Treaty::Attribute::Validation::Orchestrator::Base) do
          define_method(:collection_of_attributes) do
            @version_factory.request_factory.collection_of_attributes
          end
        end

        orchestrator_class.validate!(
          version_factory: @version_factory,
          data: request_data
        )
      end

      def adapter_strategy?
        !@version_factory.strategy_instance.direct?
      end

      def request_attributes_exist?
        return false if @version_factory.request_factory&.collection_of_attributes&.empty?

        @version_factory.request_factory.collection_of_attributes.exists?
      end
    end
  end
end
