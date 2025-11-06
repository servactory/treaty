# frozen_string_literal: true

module Treaty
  module Attribute
    module Validation
      # Validates and transforms individual attributes.
      #
      # ## Purpose
      #
      # Acts as the main interface for attribute validation and transformation.
      # Delegates option processing to OptionOrchestrator and handles nested validation.
      #
      # ## Responsibilities
      #
      # 1. **Schema Validation** - Validates DSL definition correctness
      # 2. **Value Validation** - Validates runtime data values
      # 3. **Value Transformation** - Transforms values (defaults, etc.)
      # 4. **Name Transformation** - Provides target name (for `as:` option)
      # 5. **Nested Validation** - Delegates to NestedObjectValidator/NestedArrayValidator
      #
      # ## Usage
      #
      # Used by Orchestrator to validate each attribute:
      #
      #   validator = AttributeValidator.new(attribute)
      #   validator.validate_schema!
      #   validator.validate_value!(value)
      #   transformed = validator.transform_value(value)
      #   target_name = validator.target_name
      #
      # ## Architecture
      #
      # Delegates to:
      # - `OptionOrchestrator` - Coordinates all option processors
      # - `NestedObjectValidator` - Validates nested object structures
      # - `NestedArrayValidator` - Validates nested array structures
      class AttributeValidator
        attr_reader :attribute, :option_orchestrator

        # Creates a new attribute validator instance
        #
        # @param attribute [Attribute::Base] The attribute to validate
        def initialize(attribute)
          @attribute = attribute
          @option_orchestrator = OptionOrchestrator.new(attribute)
          @nested_object_validator = nil
          @nested_array_validator = nil
        end

        # Validates the attribute schema (DSL definition)
        #
        # @raise [Treaty::Exceptions::Validation] If schema is invalid
        # @return [void]
        def validate_schema!
          option_orchestrator.validate_schema!
        end

        # Validates attribute value against all constraints
        #
        # @param value [Object] The value to validate
        # @raise [Treaty::Exceptions::Validation] If validation fails
        # @return [void]
        def validate_value!(value)
          option_orchestrator.validate_value!(value)
          validate_nested!(value) if attribute.nested? && !value.nil?
        end

        # Transforms attribute value through all modifiers
        #
        # @param value [Object] The value to transform
        # @return [Object] Transformed value
        def transform_value(value)
          option_orchestrator.transform_value(value)
        end

        # Checks if attribute name is transformed
        #
        # @return [Boolean] True if name is transformed (as: option)
        def transforms_name?
          option_orchestrator.transforms_name?
        end

        # Gets the target attribute name
        #
        # @return [Symbol] The target name (or original if not transformed)
        def target_name
          option_orchestrator.target_name
        end

        # Validates only the type constraint
        # Used by nested transformers to validate types before nested validation
        #
        # @param value [Object] The value to validate
        # @raise [Treaty::Exceptions::Validation] If type validation fails
        # @return [void]
        def validate_type!(value)
          type_processor = option_orchestrator.processor_for(:type)
          type_processor&.validate_value!(value)
        end

        # Validates only the required constraint
        # Used by nested transformers to validate presence before nested validation
        #
        # @param value [Object] The value to validate
        # @raise [Treaty::Exceptions::Validation] If required validation fails
        # @return [void]
        def validate_required!(value)
          required_processor = option_orchestrator.processor_for(:required)
          required_processor&.validate_value!(value) if attribute.options.key?(:required)
        end

        private

        # Validates nested attributes for object/array types
        #
        # @param value [Object] The value to validate
        # @raise [Treaty::Exceptions::Validation] If nested validation fails
        # @return [void]
        def validate_nested!(value)
          case attribute.type
          when :object
            nested_object_validator.validate!(value)
          when :array
            nested_array_validator.validate!(value)
          end
        end

        # Gets or creates nested object validator
        #
        # @return [NestedObjectValidator] Validator for nested objects
        def nested_object_validator
          @nested_object_validator ||= NestedObjectValidator.new(attribute)
        end

        # Gets or creates nested array validator
        #
        # @return [NestedArrayValidator] Validator for nested arrays
        def nested_array_validator
          @nested_array_validator ||= NestedArrayValidator.new(attribute)
        end
      end
    end
  end
end
