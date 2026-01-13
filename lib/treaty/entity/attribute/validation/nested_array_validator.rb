# frozen_string_literal: true

module Treaty
  module Entity
    module Attribute
      module Validation
        # Validates array elements against nested attribute definitions.
        #
        # ## Purpose
        #
        # Performs validation for nested array attributes during the validation phase.
        # Handles both simple arrays (with :_self attribute) and complex arrays (objects).
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
        # ### Simple Array (`:_self` attribute)
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
        # - `ValueExtractor` - Extracts values from Hash or PORO polymorphically
        # - Caches validators for performance
        # - Separates self validators from regular validators
        class NestedArrayValidator # rubocop:disable Metrics/ClassLength
          # Creates a new nested array validator
          #
          # @param attribute [Attribute::Base] The array-type attribute with nested attributes
          def initialize(attribute)
            @attribute = attribute
            @self_validators = nil
            @regular_validators = nil
            @self_object_attribute = nil
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

          # Validates array item for simple arrays (with :_self attribute)
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
                  I18n.t(
                    "treaty.attributes.validators.nested.array.element_validation_error",
                    attribute: @attribute.name,
                    index:,
                    errors: errors.join("; ")
                  )
          end

          # Validates array item for complex arrays (with regular attributes or object :_self)
          #
          # @param array_item [Hash, Object] Item from array
          # @param index [Integer] Array index for error messages
          # @raise [Treaty::Exceptions::Validation] If validation fails
          # @return [void]
          def validate_regular_array_item!(array_item, index)
            if self_object_attribute
              validate_self_object_item!(array_item, index, self_object_attribute)
            else
              validate_hash_array_item!(array_item, index)
            end
          end

          # Gets cached self-object attribute or finds it
          #
          # @return [Attribute::Base, nil] Self-object attribute or nil
          def self_object_attribute
            return @self_object_attribute if defined?(@self_object_attribute_loaded)

            @self_object_attribute_loaded = true
            @self_object_attribute = find_self_object_attribute
          end

          # Finds object :_self attribute if present
          #
          # @return [Attribute::Base, nil] Self-object attribute or nil
          def find_self_object_attribute
            @attribute.collection_of_attributes.find do |nested_attribute|
              nested_attribute.name == :_self && nested_attribute.type == :object
            end
          end

          # Validates array item against object :_self definition
          #
          # @param array_item [Hash, Object] Item from array
          # @param index [Integer] Array index for error messages
          # @param self_object_attribute [Attribute::Base] The object :_self attribute
          # @raise [Treaty::Exceptions::Validation] If validation fails
          # @return [void]
          def validate_self_object_item!(array_item, index, self_object_attribute)
            validate_self_object_type!(array_item, index, self_object_attribute)

            return unless self_object_attribute.nested?

            validate_self_object_attributes!(array_item, index, self_object_attribute)
          end

          # Validates type of self-object array item
          #
          # @param array_item [Hash, Object] Item from array
          # @param index [Integer] Array index for error messages
          # @param self_object_attribute [Attribute::Base] The object :_self attribute
          # @raise [Treaty::Exceptions::Validation] If type doesn't match
          # @return [void]
          def validate_self_object_type!(array_item, index, self_object_attribute)
            expected_type = self_object_attribute.custom_type || Hash

            return if array_item.is_a?(expected_type)

            raise Treaty::Exceptions::Validation,
                  I18n.t(
                    "treaty.attributes.validators.nested.array.element_type_error",
                    attribute: @attribute.name,
                    index:,
                    actual: array_item.class
                  )
          end

          # Validates nested attributes of self-object array item
          #
          # @param array_item [Hash, Object] Item from array
          # @param index [Integer] Array index for error messages
          # @param self_object_attribute [Attribute::Base] The object :_self attribute
          # @raise [Treaty::Exceptions::Validation] If nested validation fails
          # @return [void]
          def validate_self_object_attributes!(array_item, index, self_object_attribute) # rubocop:disable Metrics/MethodLength
            self_object_attribute.collection_of_attributes.each do |nested_attribute|
              nested_value = ValueExtractor.extract(array_item, nested_attribute.name)
              validator = AttributeValidator.new(nested_attribute)
              validator.validate_schema!

              begin
                validator.validate_value!(nested_value)
              rescue Treaty::Exceptions::Validation => e
                raise Treaty::Exceptions::Validation,
                      I18n.t(
                        "treaty.attributes.validators.nested.array.attribute_error",
                        attribute: @attribute.name,
                        index:,
                        message: e.message
                      )
              end
            end
          end

          # Validates array item as Hash (original behavior)
          #
          # @param array_item [Hash] Hash object from array
          # @param index [Integer] Array index for error messages
          # @raise [Treaty::Exceptions::Validation] If item is not Hash or validation fails
          # @return [void]
          def validate_hash_array_item!(array_item, index) # rubocop:disable Metrics/MethodLength
            unless array_item.is_a?(Hash)
              raise Treaty::Exceptions::Validation,
                    I18n.t(
                      "treaty.attributes.validators.nested.array.element_type_error",
                      attribute: @attribute.name,
                      index:,
                      actual: array_item.class
                    )
            end

            regular_validators.each do |nested_attribute, validator|
              nested_value = array_item.fetch(nested_attribute.name, nil)
              validator.validate_value!(nested_value)
            rescue Treaty::Exceptions::Validation => e
              raise Treaty::Exceptions::Validation,
                    I18n.t(
                      "treaty.attributes.validators.nested.array.attribute_error",
                      attribute: @attribute.name,
                      index:,
                      message: e.message
                    )
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
                      .select { |nested_attribute| nested_attribute.name == :_self }
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
                      .reject { |nested_attribute| nested_attribute.name == :_self }
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
end
