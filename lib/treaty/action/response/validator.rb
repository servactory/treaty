# frozen_string_literal: true

module Treaty
  module Action
    module Response
      # Validates service response data against schema.
      #
      # ## Purpose
      #
      # Validates response data from service execution against the response
      # schema defined in the treaty version. Ensures service output matches
      # the documented API contract.
      #
      # ## Usage
      #
      # Called internally by:
      # - Versions::Execution::Response (after service execution)
      #
      # ## Validation Flow
      #
      # 1. Check if response schema is defined
      # 2. Create dynamic Orchestrator with version's response attributes
      # 3. Run validation pipeline (validate + transform)
      # 4. Return validated/transformed data or raise error
      #
      # ## Error Handling
      #
      # Raises Treaty::Exceptions::Validation with detailed messages
      # including attribute path and specific validation failures.
      #
      # ## Difference from Request::Validator
      #
      # - Validates service output, not controller params
      # - Response attributes are optional by default
      # - Used after service execution, not before
      #
      # ## Example
      #
      #   # Typically called via class method:
      #   validated = Response::Validator.validate!(
      #     version_factory: version_factory,
      #     response_data: service_result
      #   )
      #
      #   # validated contains transformed response for client
      class Validator
        class << self
          # Validates response data
          #
          # @param version_factory [Versions::Factory] Version with response schema
          # @param response_data [Hash] Response data from service
          # @return [Hash] Validated and transformed response
          # @raise [Treaty::Exceptions::Validation] If validation fails
          def validate!(version_factory:, response_data: {})
            new(version_factory:, response_data:).validate!
          end
        end

        # Creates new validator instance
        #
        # @param version_factory [Versions::Factory] Version with response schema
        # @param response_data [Hash] Response data to validate
        def initialize(version_factory:, response_data: {})
          @version_factory = version_factory
          @response_data = response_data
        end

        # Runs validation pipeline
        #
        # @return [Hash] Validated and transformed response
        # @raise [Treaty::Exceptions::Validation] If validation fails
        def validate!
          validate_response_attributes!
        end

        private

        # Validates and transforms response data
        #
        # Creates dynamic Orchestrator class that uses version's response
        # attributes for validation. Returns raw data if no schema defined.
        #
        # @return [Hash] Validated and transformed data
        # @raise [Treaty::Exceptions::Validation] If validation fails
        def validate_response_attributes!
          return @response_data unless response_attributes_exist?

          orchestrator_class = Class.new(Treaty::Entity::Attribute::Validation::Orchestrator::Base) do
            define_method(:collection_of_attributes) do
              @version_factory.response_factory.collection_of_attributes
            end
          end

          orchestrator_class.validate!(
            version_factory: @version_factory,
            data: @response_data
          )
        end

        # Checks if response schema is defined for this version
        #
        # @return [Boolean] True if response attributes exist
        def response_attributes_exist?
          return false if @version_factory.response_factory&.collection_of_attributes&.empty?

          @version_factory.response_factory.collection_of_attributes.exists?
        end
      end
    end
  end
end
