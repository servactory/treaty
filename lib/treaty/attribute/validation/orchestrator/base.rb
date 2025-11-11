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

          # Validates and transforms all attributes
          # Iterates through attributes, processes them, handles :_self objects
          #
          # @return [Hash] Transformed data with all attributes processed
          def validate!
            transformed_data = {}

            collection_of_attributes.each do |attribute|
              transformed_value = validate_and_transform_attribute!(attribute)

              if attribute.name == SELF_SCOPE && attribute.type == :object
                # For object :_self, merge nested attributes to root
                transformed_data.merge!(transformed_value)
              else
                transformed_data[attribute.name] = transformed_value
              end
            end

            transformed_data
          end

          private

          # Returns collection of attributes for this context
          # Must be implemented in subclasses
          #
          # @raise [Treaty::Exceptions::Validation] If not implemented
          # @return [Array<Attribute>] Collection of attributes
          def collection_of_attributes
            raise Treaty::Exceptions::Validation,
                  I18n.t("treaty.attributes.validators.nested.orchestrator.collection_not_implemented")
          end

          # Gets cached validators for attributes or builds them
          #
          # @return [Hash] Hash of attribute => validator
          def validators_for_attributes
            @validators_cache ||= build_validators_for_attributes
          end

          # Builds validators for all attributes
          #
          # @return [Hash] Hash of attribute => validator
          def build_validators_for_attributes
            collection_of_attributes.each_with_object({}) do |attribute, cache|
              validator = AttributeValidator.new(attribute)
              validator.validate_schema!
              cache[attribute] = validator
            end
          end

          # Validates and transforms a single attribute
          # Handles both nested and regular attributes
          #
          # @param attribute [Attribute] The attribute to process
          # @return [Object] Transformed attribute value
          def validate_and_transform_attribute!(attribute) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
            validator = validators_for_attributes[attribute]
            source_name = attribute.name

            # For :_self object, get data from root; otherwise from attribute key
            if attribute.name == SELF_SCOPE && attribute.type == :object
              value = data
            else
              value = data.fetch(source_name, nil)
            end

            if attribute.nested?
              transformed_value = validate_and_transform_nested(attribute, value, validator)
            else
              validator.validate_value!(value)
              transformed_value = validator.transform_value(value)
            end

            # Apply target name transformation if needed
            target_name = validator.target_name

            # For :_self object, return the transformed nested data directly
            if attribute.name == SELF_SCOPE && attribute.type == :object
              transformed_value
            else
              transformed_value
            end
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
