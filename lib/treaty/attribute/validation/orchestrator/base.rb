# frozen_string_literal: true

module Treaty
  module Attribute
    module Validation
      module Orchestrator
        # Base orchestrator for validating and transforming data according to treaty definitions.
        #
        # ## Purpose
        #
        # Coordinates the validation and transformation of request/response data for a specific
        # API version. Processes all scopes and their attributes, applying validations and
        # transformations defined in the treaty DSL.
        #
        # ## Responsibilities
        #
        # 1. **Scope Processing** - Iterates through all defined scopes
        # 2. **Attribute Validation** - Validates each attribute's value
        # 3. **Data Transformation** - Transforms values (defaults, renaming)
        # 4. **Nested Handling** - Delegates nested structures to NestedTransformer
        # 5. **Result Assembly** - Builds final transformed data structure
        #
        # ## Usage
        #
        # Subclasses must implement:
        # - `collection_of_scopes` - Returns scopes for this context (request/response)
        # - `scope_data_for(name)` - Extracts data for a specific scope
        #
        # Example:
        #   orchestrator = Request::Orchestrator.new(version_factory: factory, data: params)
        #   validated_data = orchestrator.validate!
        #
        # ## Special Scopes
        #
        # - Normal scope: `{ scope_name: { ... } }`
        # - Self scope (`:_self`): Attributes merged directly into parent
        #
        # ## Architecture
        #
        # Uses:
        # - `AttributeValidator` - Validates individual attributes
        # - `NestedTransformer` - Handles nested objects and arrays
        #
        # The refactored design separates concerns:
        # - Orchestrator: High-level flow and scope iteration
        # - Validator: Individual attribute validation
        # - Transformer: Nested structure transformation
        class Base
          SELF_SCOPE = :_self
          private_constant :SELF_SCOPE

          attr_reader :version_factory, :data

          # Class-level factory method for validation
          # Creates instance and calls validate!
          #
          # @param args [Hash] Arguments passed to initialize
          # @return [Hash] Validated and transformed data
          def self.validate!(...)
            new(...).validate!
          end

          # Creates a new orchestrator instance
          #
          # @param version_factory [VersionFactory] Factory containing version info
          # @param data [Hash] Data to validate and transform (default: {})
          def initialize(version_factory:, data: {})
            @version_factory = version_factory
            @data = data
          end

          # Validates and transforms all scopes
          # Iterates through scopes, processes attributes, handles :_self scope
          #
          # @return [Hash] Transformed data with all scopes processed
          def validate!
            transformed_data = {}

            collection_of_scopes.each do |scope_factory|
              transformed_scope_data = validate_and_transform_scope!(scope_factory)
              transformed_data[scope_factory.name] = transformed_scope_data if scope_factory.name != SELF_SCOPE
              transformed_data.merge!(transformed_scope_data) if scope_factory.name == SELF_SCOPE
            end

            transformed_data
          end

          private

          # Returns collection of scopes for this context
          # Must be implemented in subclasses
          #
          # @raise [Treaty::Exceptions::Validation] If not implemented
          # @return [Array<ScopeFactory>] Collection of scope factories
          def collection_of_scopes
            raise Treaty::Exceptions::Validation,
                  I18n.t("treaty.orchestrator.collection_not_implemented")
          end

          # Validates all attributes in a scope (deprecated, not used)
          #
          # @param scope_factory [ScopeFactory] The scope to validate
          # @return [void]
          def validate_scope!(scope_factory)
            scope_data = scope_data_for(scope_factory.name)

            validators_for_scope(scope_factory).each do |attribute, validator|
              value = scope_data.fetch(attribute.name, nil)
              validator.validate_value!(value)
            end
          end

          # Gets cached validators for scope or builds them
          #
          # @param scope_factory [ScopeFactory] The scope factory
          # @return [Hash] Hash of attribute => validator
          def validators_for_scope(scope_factory)
            @validators_cache ||= {}
            @validators_cache[scope_factory] ||= build_validators_for_scope(scope_factory)
          end

          # Builds validators for all attributes in a scope
          #
          # @param scope_factory [ScopeFactory] The scope factory
          # @return [Hash] Hash of attribute => validator
          def build_validators_for_scope(scope_factory)
            scope_factory.collection_of_attributes.each_with_object({}) do |attribute, cache|
              validator = AttributeValidator.new(attribute)
              validator.validate_schema!
              cache[attribute] = validator
            end
          end

          # Extracts data for a specific scope
          # Must be implemented in subclasses
          #
          # @param _name [Symbol] The scope name
          # @raise [Treaty::Exceptions::Validation] If not implemented
          # @return [Hash] Scope data
          def scope_data_for(_name)
            raise Treaty::Exceptions::Validation,
                  I18n.t("treaty.orchestrator.scope_data_not_implemented")
          end

          # Validates and transforms all attributes in a scope
          # Handles both nested and regular attributes
          #
          # @param scope_factory [ScopeFactory] The scope to process
          # @return [Hash] Transformed scope data
          def validate_and_transform_scope!(scope_factory) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
            scope_data = scope_data_for(scope_factory.name)

            return scope_data if scope_factory.collection_of_attributes.empty?

            transformed_scope_data = {}

            validators_for_scope(scope_factory).each do |attribute, validator|
              source_name = attribute.name
              value = scope_data.fetch(source_name, nil)

              if attribute.nested?
                transformed_value = validate_and_transform_nested(attribute, value, validator)
              else
                validator.validate_value!(value)
                transformed_value = validator.transform_value(value)
              end

              target_name = validator.target_name

              transformed_scope_data[target_name] = transformed_value
            end

            transformed_scope_data
          end

          # Validates and transforms nested attribute (object/array)
          # Delegates transformation to NestedTransformer
          #
          # @param attribute [Attribute::Base] The nested attribute
          # @param value [Object] The value to validate and transform
          # @param validator [AttributeValidator] The validator instance
          # @return [Object] Transformed nested value
          def validate_and_transform_nested(attribute, value, validator)
            validator.validate_type!(value) unless value.nil?
            validator.validate_required!(value)

            transformer = NestedTransformer.new(attribute)
            transformer.transform(value)
          end
        end
      end
    end
  end
end
