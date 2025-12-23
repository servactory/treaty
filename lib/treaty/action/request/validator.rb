# frozen_string_literal: true

module Treaty
  module Action
    module Request
      # Validates incoming request parameters against schema.
      #
      # ## Purpose
      #
      # Validates incoming request params against the request schema defined
      # in the treaty version. Runs all validators (required, type, inclusion,
      # format) and transformations (default, cast, transform, as).
      #
      # ## Usage
      #
      # Called internally by:
      # - Versions::Execution::Base (before delegating to service)
      #
      # ## Validation Flow
      #
      # 1. Convert ActionController::Parameters to hash if needed
      # 2. Check if request schema is defined
      # 3. Create dynamic Orchestrator with version's attributes
      # 4. Run validation pipeline (validate + transform)
      # 5. Return validated/transformed params or raise error
      #
      # ## Error Handling
      #
      # Raises Treaty::Exceptions::Validation with detailed messages
      # including attribute path and specific validation failures.
      #
      # ## Example
      #
      #   # Typically called via class method:
      #   validated = Request::Validator.validate!(
      #     params: controller.params,
      #     version_factory: version_factory
      #   )
      #
      #   # validated contains transformed params ready for service
      class Validator
        class << self
          # Validates request parameters
          #
          # @param params [Hash, ActionController::Parameters] Request params
          # @param version_factory [Treaty::Action::Versions::Factory] Version with request schema
          # @return [Hash] Validated and transformed parameters
          # @raise [Treaty::Exceptions::Validation] If validation fails
          def validate!(params:, version_factory:)
            new(params:, version_factory:).validate!
          end
        end

        # Creates new validator instance
        #
        # @param params [Hash, ActionController::Parameters] Request params
        # @param version_factory [Treaty::Action::Versions::Factory] Version with request schema
        def initialize(params:, version_factory:)
          @params = params
          @version_factory = version_factory
        end

        # Runs validation pipeline
        #
        # @return [Hash] Validated and transformed parameters
        # @raise [Treaty::Exceptions::Validation] If validation fails
        def validate!
          validate_request_attributes!
        end

        private

        # Converts params to plain hash
        #
        # Handles both ActionController::Parameters (with to_unsafe_h)
        # and plain Hash objects.
        #
        # @return [Hash] Plain hash of request data
        def request_data
          @request_data ||= begin
            @params.to_unsafe_h
          rescue NoMethodError
            @params
          end
        end

        # Validates and transforms request data
        #
        # Creates dynamic Orchestrator class that uses version's request
        # attributes for validation. Returns raw data if no schema defined.
        #
        # @return [Hash] Validated and transformed data
        # @raise [Treaty::Exceptions::Validation] If validation fails
        def validate_request_attributes!
          return request_data unless request_attributes_exist?

          orchestrator_class = Class.new(Treaty::Entity::Attribute::Validation::Orchestrator::Base) do
            define_method(:collection_of_attributes) do
              @version_factory.request_factory.collection_of_attributes
            end
          end

          orchestrator_class.validate!(
            version_factory: @version_factory,
            data: request_data
          )
        end

        # Checks if request schema is defined for this version
        #
        # @return [Boolean] True if request attributes exist
        def request_attributes_exist?
          return false if @version_factory.request_factory&.collection_of_attributes&.empty?

          @version_factory.request_factory.collection_of_attributes.exists?
        end
      end
    end
  end
end
