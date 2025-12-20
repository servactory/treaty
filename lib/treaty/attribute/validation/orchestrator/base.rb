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
        # API version. Processes all attributes, applying validations and transformations
        # defined in the treaty DSL.
        #
        # ## Responsibilities
        #
        # 1. **Attribute Processing** - Iterates through all defined attributes
        # 2. **Attribute Validation** - Validates each attribute's value
        # 3. **Data Transformation** - Transforms values (defaults, renaming)
        # 4. **Nested Handling** - Delegates nested structures to NestedTransformer
        # 5. **Result Assembly** - Builds final transformed data structure
        #
        # ## Usage
        #
        # Subclasses must implement:
        # - `collection_of_attributes` - Returns attributes for this context (request/response)
        #
        # Example:
        #   orchestrator = Request::Orchestrator.new(version_factory: factory, data: params)
        #   validated_data = orchestrator.validate!
        #
        # ## Special Case: object :_self
        #
        # - Normal object: `{ object_name: { ... } }`
        # - Self object (`:_self`): Attributes merged directly into parent
        #
        # ## Architecture
        #
        # Uses:
        # - `AttributeValidator` - Validates individual attributes
        # - `NestedTransformer` - Handles nested objects and arrays
        #
        # The design separates concerns:
        # - Orchestrator: High-level flow and attribute iteration
        # - Validator: Individual attribute validation
        # - Transformer: Nested structure transformation
        class Base
          SELF_OBJECT = :_self
          private_constant :SELF_OBJECT

          attr_reader :version_factory, :data, :configuration

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
          # @param version_factory [VersionFactory] Factory containing version info (can be nil for Entity)
          # @param data [Hash] Data to validate and transform (default: {})
          # @param configuration [Treaty::Entity::Configuration, nil] Configuration with default options
          def initialize(version_factory:, data: {}, configuration: nil)
            @version_factory = version_factory
            @data = data
            @configuration = configuration
          end

          # Validates and transforms all attributes
          # Iterates through attributes, processes them, handles :_self objects
          # Skips attributes with false conditional (if/unless option)
          #
          # @return [Hash] Transformed data with all attributes processed
          def validate! # rubocop:disable Metrics/MethodLength
            transformed_data = {}

            collection_of_attributes.each do |attribute|
              # Check if conditional (if/unless option) - skip attribute if condition evaluates to skip
              next unless should_process_attribute?(attribute)

              transformed_value = validate_and_transform_attribute!(attribute)

              if attribute.name == SELF_OBJECT && attribute.type == :object
                # For object :_self, merge nested attributes to root
                transformed_data.merge!(transformed_value)
              else
                transformed_data[attribute.name] = transformed_value
              end
            end

            transformed_data
          end

          private

          # Returns the conditional option name if present (:if or :unless)
          # Raises error if both are present (mutual exclusivity)
          #
          # @param attribute [Attribute::Base] The attribute to check
          # @raise [Treaty::Exceptions::Validation] If both :if and :unless are present
          # @return [Symbol, nil] :if, :unless, or nil
          def conditional_option_for(attribute) # rubocop:disable Metrics/MethodLength
            has_if = attribute.options.key?(:if)
            has_unless = attribute.options.key?(:unless)

            if has_if && has_unless
              raise Treaty::Exceptions::Validation,
                    I18n.t(
                      "treaty.attributes.conditionals.mutual_exclusivity_error",
                      attribute: attribute.name
                    )
            end

            return :if if has_if
            return :unless if has_unless

            nil
          end

          # Checks if an attribute should be processed based on its conditional (if/unless option)
          # Returns true if no conditional is defined or if conditional evaluates appropriately
          #
          # @param attribute [Attribute::Base] The attribute to check
          # @return [Boolean] True if attribute should be processed, false to skip it
          def should_process_attribute?(attribute)
            # Check if attribute has a conditional option
            conditional_type = conditional_option_for(attribute)
            return true if conditional_type.nil?

            # Get cached conditional processor
            conditional = conditionals_for_attributes[attribute]
            return true if conditional.nil?

            # Evaluate condition with raw data
            # The processor's evaluate_condition already handles if/unless logic
            conditional.evaluate_condition(data)
          end

          # Returns collection of attributes for this context
          # Must be implemented in subclasses
          #
          # @raise [Treaty::Exceptions::Validation] If not implemented
          # @return [Treaty::Attribute::Collection] Collection of attributes
          def collection_of_attributes
            raise Treaty::Exceptions::Validation,
                  I18n.t("treaty.attributes.validators.nested.orchestrator.collection_not_implemented")
          end

          # Gets cached validators for attributes or builds them
          #
          # @return [Hash] Hash of attribute => validator
          def validators_for_attributes
            @validators_for_attributes ||= build_validators_for_attributes
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

          # Gets cached conditional processors for attributes or builds them
          #
          # @return [Hash] Hash of attribute => conditional processor
          def conditionals_for_attributes
            @conditionals_for_attributes ||= build_conditionals_for_attributes
          end

          # Builds conditional processors for attributes with :if or :unless option
          # Validates schema at definition time for performance
          #
          # @return [Hash] Hash of attribute => conditional processor
          def build_conditionals_for_attributes # rubocop:disable Metrics/MethodLength
            collection_of_attributes.each_with_object({}) do |attribute, cache|
              # Get conditional option name (:if or :unless)
              conditional_type = conditional_option_for(attribute)
              next if conditional_type.nil?

              processor_class = Option::Registry.processor_for(conditional_type)
              next if processor_class.nil?

              # Create processor instance
              conditional = processor_class.new(
                attribute_name: attribute.name,
                attribute_type: attribute.type,
                option_schema: attribute.options.fetch(conditional_type)
              )

              # Validate schema at definition time (not runtime)
              conditional.validate_schema!

              cache[attribute] = conditional
            end
          end

          # Validates and transforms a single attribute
          # Handles both nested and regular attributes
          #
          # @param attribute [Attribute] The attribute to process
          # @return [Object] Transformed attribute value
          def validate_and_transform_attribute!(attribute) # rubocop:disable Metrics/MethodLength
            validator = validators_for_attributes.fetch(attribute)

            # For :_self object, get data from root; otherwise from attribute key
            value = if attribute.name == SELF_OBJECT && attribute.type == :object
                      data
                    else
                      data.fetch(attribute.name, nil)
                    end

            if attribute.nested?
              validate_and_transform_nested(attribute, value, validator)
            else
              validator.validate_value!(value)
              validator.transform_value(value, data)
            end
          end

          # Validates and transforms nested attribute (object/array)
          # Delegates transformation to NestedTransformer
          #
          # @param attribute [Attribute::Base] The nested attribute
          # @param value [Object, nil] The value to validate and transform
          # @param validator [AttributeValidator] The validator instance
          # @return [Object, nil] Transformed nested value or nil
          #
          # @note Flow control:
          #   - If value is nil and attribute is required → validate_required! raises exception
          #   - If value is nil and attribute is optional → validate_required! does nothing, returns nil
          #   - If value is not nil → proceeds to transformation (value guaranteed non-nil)
          def validate_and_transform_nested(attribute, value, validator)
            # Step 1: Validate type if value is present
            validator.validate_type!(value) unless value.nil?

            # Step 2: Validate required constraint
            # This will raise an exception if attribute is required and value is nil
            validator.validate_required!(value)

            # Step 3: Early return for nil values
            # Only reaches here if attribute is optional and value is nil
            return nil if value.nil?

            # Step 4: Transform non-nil value
            # At this point, value is guaranteed to be non-nil
            # Pass full root data as context for computed modifiers
            transformer = NestedTransformer.new(attribute)
            transformer.transform(value, data)
          end
        end
      end
    end
  end
end
