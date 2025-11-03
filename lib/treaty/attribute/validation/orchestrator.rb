# frozen_string_literal: true

module Treaty
  module Attribute
    module Validation
      # Orchestrates validation for a specific version's attributes
      class Orchestrator
        attr_reader :version_factory, :request_data, :scope_type

        def initialize(version_factory:, request_data: {}, scope_type: :request)
          @version_factory = version_factory
          @request_data = request_data
          @scope_type = scope_type
        end

        # Validates all attributes for the version
        def validate!
          # Only validate for adapter strategy
          return unless version_factory.strategy_instance.adapter?

          # Validate schemas first (structure and options)
          validate_schemas!

          # Then validate values if request_data is provided
          validate_values! unless request_data.empty?
        end

        private

        def validate_schemas!
          case scope_type
          when :request
            validate_request_schemas!
          when :response
            validate_response_schemas!
          end
        end

        def validate_values!
          case scope_type
          when :request
            validate_request_values!
          when :response
            validate_response_values!
          end
        end

        def validate_request_schemas!
          return unless version_factory.request_factory

          version_factory.request_factory.collection_of_scopes.each do |scope_factory|
            validate_scope_schemas!(scope_factory)
          end
        end

        def validate_response_schemas!
          return unless version_factory.response_factory

          version_factory.response_factory.collection_of_scopes.each do |scope_factory| # rubocop:disable Lint/UnreachableLoop
            validate_scope_schemas!(scope_factory)
            break # Only validate first scope for response
          end
        end

        def validate_scope_schemas!(scope_factory)
          scope_factory.collection_of_attributes.each do |attribute|
            validator = AttributeValidator.new(attribute)
            validator.validate_schema!
          end
        end

        def validate_request_values!
          return unless version_factory.request_factory

          version_factory.request_factory.collection_of_scopes.each do |scope_factory|
            scope_data = extract_scope_data(scope_factory.name)
            validate_scope_values!(scope_factory, scope_data)
          end
        end

        def validate_response_values!
          return unless version_factory.response_factory

          version_factory.response_factory.collection_of_scopes.each do |scope_factory| # rubocop:disable Lint/UnreachableLoop
            validate_scope_values!(scope_factory, request_data)
            break # Only validate first scope for response
          end
        end

        def validate_scope_values!(scope_factory, scope_data)
          scope_factory.collection_of_attributes.each do |attribute|
            validator = AttributeValidator.new(attribute)

            value = scope_data[attribute.name]
            validator.validate_value!(value)
          end
        end

        def extract_scope_data(scope_name)
          # If scope is :self, it's the root level
          return request_data if scope_name == :self

          # Otherwise, get data from the named scope
          request_data.fetch(scope_name, {})
        end
      end
    end
  end
end
