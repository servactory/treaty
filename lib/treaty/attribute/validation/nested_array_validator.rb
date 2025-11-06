# frozen_string_literal: true

module Treaty
  module Attribute
    module Validation
      # Validates array elements against nested attribute definitions.
      #
      # ## Purpose
      #
      # Performs validation for nested array attributes during the validation phase.
      # Handles both simple arrays (with :_self scope) and complex arrays (objects).
      #
      # ## Responsibilities
      #
      # 1. **Simple Array Validation** - Validates primitive values in arrays
      # 2. **Complex Array Validation** - Validates hash objects within arrays
      # 3. **Error Context** - Provides clear error messages with array index
      # 4. **Type Checking** - Ensures elements match expected types
      #
      # ## Array Types
      #
      # ### Simple Array (`:_self` scope)
      # Array containing primitive values (strings, integers, etc.)
      #
      # ```ruby
      # array :tags do
      #   string :_self  # Array of strings
      # end
      # ```
      #
      # Validates: `["ruby", "rails", "api"]`
      #
      # ### Complex Array (regular attributes)
      # Array containing hash objects with defined structure
      #
      # ```ruby
      # array :authors do
      #   string :name, :required
      #   string :email
      # end
      # ```
      #
      # Validates: `[{ name: "Alice", email: "alice@example.com" }, ...]`
      #
      # ## Usage
      #
      # Called by AttributeValidator for nested arrays:
      #
      #   validator = NestedArrayValidator.new(attribute)
      #   validator.validate!(array_value)
      #
      # ## Error Handling
      #
      # Provides contextual error messages including:
      # - Array attribute name
      # - Element index (0-based)
      # - Specific validation error
      #
      # Example error:
      #   "Error in array 'tags' at index 2: Element must match one of the defined types"
      #
      # ## Architecture
      #
      # Uses:
      # - `AttributeValidator` - Validates individual elements
      # - Caches validators for performance
      # - Separates self validators from regular validators
      class NestedArrayValidator
        # Creates a new nested array validator
        #
        # @param attribute [Attribute::Base] The array-type attribute with nested attributes
        def initialize(attribute)
          @attribute = attribute
          @self_validators = nil
          @regular_validators = nil
        end

        # Validates all items in an array
        # Skips validation if value is not an Array
        #
        # @param array [Array] The array to validate
        # @raise [Treaty::Exceptions::Validation] If any item validation fails
        # @return [void]
        def validate!(array)
          return unless array.is_a?(Array)

          array.each_with_index do |array_item, index|
            validate_self_array_item!(array_item, index) if self_validators.any?

            validate_regular_array_item!(array_item, index) if regular_validators.any?
          end
        end

        private

        # Validates array item for simple arrays (with :_self scope)
        # Simple array contains primitive values: strings, integers, datetimes, etc.
        # Example: ["ruby", "rails", "api"] where each item is a String
        #
        # @param array_item [String, Integer, DateTime] Primitive value from simple array
        # @param index [Integer] Array index for error messages
        # @raise [Treaty::Exceptions::Validation] If primitive value doesn't match defined type
        # @return [void]
        def validate_self_array_item!(array_item, index) # rubocop:disable Metrics/MethodLength
          errors = []

          validated = self_validators.any? do |validator|
            validator.validate_value!(array_item)
            true
          rescue Treaty::Exceptions::Validation => e
            errors << e.message
            false
          end

          return if validated

          raise Treaty::Exceptions::Validation,
                I18n.t("treaty.nested.array.element_validation_error",
                       attribute: @attribute.name,
                       index: index,
                       errors: errors.join('; '))
        end

        # Validates array item for complex arrays (with regular attributes)
        # Complex array contains hash objects with defined structure
        # Example: [{ name: "Alice", email: "alice@example.com" }, ...] where each item is a Hash
        #
        # @param array_item [Hash] Hash object from complex array
        # @param index [Integer] Array index for error messages
        # @raise [Treaty::Exceptions::Validation] If item is not Hash or nested validation fails
        # @return [void]
        def validate_regular_array_item!(array_item, index) # rubocop:disable Metrics/MethodLength
          unless array_item.is_a?(Hash)
            raise Treaty::Exceptions::Validation,
                  I18n.t("treaty.nested.array.element_type_error",
                         attribute: @attribute.name,
                         index: index,
                         actual: array_item.class)
          end

          regular_validators.each do |nested_attribute, validator|
            nested_value = array_item.fetch(nested_attribute.name, nil)
            validator.validate_value!(nested_value)
          rescue Treaty::Exceptions::Validation => e
            raise Treaty::Exceptions::Validation,
                  I18n.t("treaty.nested.array.attribute_error",
                         attribute: @attribute.name,
                         index: index,
                         message: e.message)
          end
        end

        ########################################################################

        # Gets cached self validators or builds them
        #
        # @return [Array<AttributeValidator>] Validators for :_self attributes
        def self_validators
          @self_validators ||= build_self_validators
        end

        # Gets cached regular validators or builds them
        #
        # @return [Hash] Hash of nested_attribute => validator
        def regular_validators
          @regular_validators ||= build_regular_validators
        end

        ########################################################################

        # Builds validators for :_self attributes (simple array elements)
        #
        # @return [Array<AttributeValidator>] Array of validators
        def build_self_validators
          @attribute.collection_of_attributes
                    .select { |attr| attr.name == :_self }
                    .map do |self_attribute|
            validator = AttributeValidator.new(self_attribute)
            validator.validate_schema!
            validator
          end
        end

        # Builds validators for regular attributes (complex array elements)
        #
        # @return [Hash] Hash of nested_attribute => validator
        def build_regular_validators
          @attribute.collection_of_attributes
                    .reject { |attr| attr.name == :_self }
                    .each_with_object({}) do |nested_attribute, cache|
            validator = AttributeValidator.new(nested_attribute)
            validator.validate_schema!
            cache[nested_attribute] = validator
          end
        end
      end
    end
  end
end
