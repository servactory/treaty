# frozen_string_literal: true

module Treaty
  module Attribute
    module Option
      module Validators
        # Validates that attribute value matches the declared type.
        #
        # ## Supported Types
        #
        # - `:integer` - Ruby Integer
        # - `:string` - Ruby String
        # - `:boolean` - Ruby TrueClass or FalseClass
        # - `:object` - Ruby Hash (for nested objects)
        # - `:array` - Ruby Array (for collections)
        # - `:datetime` - Ruby DateTime, Time, or Date
        #
        # ## Usage Examples
        #
        # Simple types:
        #   integer :age
        #   string :name
        #   boolean :published
        #   datetime :created_at
        #
        # Nested structures:
        #   object :author do
        #     string :name
        #   end
        #
        #   array :tags do
        #     string :_self  # Simple array of strings
        #   end
        #
        # ## Validation Rules
        #
        # - Validates only non-nil values (nil handling is done by RequiredValidator)
        # - Type mismatch raises Treaty::Exceptions::Validation
        # - Datetime accepts DateTime, Time, or Date objects
        #
        # ## Note
        #
        # TypeValidator doesn't use option_schema - it validates based on attribute_type.
        # This validator is always active for all attributes.
        class TypeValidator < Treaty::Attribute::Option::Base
          ALLOWED_TYPES = %i[integer string boolean object array datetime].freeze

          # Validates that the attribute type is one of the allowed types
          #
          # @raise [Treaty::Exceptions::Validation] If type is not allowed
          # @return [void]
          def validate_schema!
            return if ALLOWED_TYPES.include?(@attribute_type)

            raise Treaty::Exceptions::Validation,
                  I18n.t(
                    "treaty.attributes.validators.type.unknown_type",
                    type: @attribute_type,
                    attribute: @attribute_name,
                    allowed: ALLOWED_TYPES.join(", ")
                  )
          end

          # Validates that the value matches the declared type
          # Skips validation for nil values (handled by RequiredValidator)
          #
          # @param value [Object] The value to validate
          # @raise [Treaty::Exceptions::Validation] If value type doesn't match
          # @return [void]
          def validate_value!(value) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
            return if value.nil? # Type validation doesn't check for nil, required does.

            case @attribute_type
            when :integer
              validate_integer!(value)
            when :string
              validate_string!(value)
            when :boolean
              validate_boolean!(value)
            when :object
              validate_object!(value)
            when :array
              validate_array!(value)
            when :datetime
              validate_datetime!(value)
            end
          end

          private

          # Common type validation logic
          # Checks if value matches expected type and raises exception with appropriate message
          #
          # @param value [Object] The value to validate
          # @param expected_type [Symbol] The expected type symbol
          # @yield Block that returns true if value is valid
          # @raise [Treaty::Exceptions::Validation] If type validation fails
          # @return [void]
          def validate_type!(value, expected_type)
            return if yield(value)

            actual_type = value.class

            attributes = {
              attribute: @attribute_name,
              value:,
              expected_type:,
              actual_type:
            }

            message = resolve_custom_message(**attributes) || default_message(**attributes)

            raise Treaty::Exceptions::Validation, message
          end

          # Generates default error message for type mismatch using I18n
          #
          # @param attribute [Symbol] The attribute name
          # @param expected_type [Symbol] The expected type
          # @param actual_type [Class] The actual class of the value
          # @return [String] Default error message
          def default_message(attribute:, expected_type:, actual_type:, **)
            I18n.t(
              "treaty.attributes.validators.type.mismatch.#{expected_type}",
              attribute:,
              actual: actual_type
            )
          end

          # Validates that value is an Integer
          #
          # @param value [Object] The value to validate
          # @raise [Treaty::Exceptions::Validation] If value is not an Integer
          # @return [void]
          def validate_integer!(value)
            validate_type!(value, :integer) { |v| v.is_a?(Integer) }
          end

          # Validates that value is a String
          #
          # @param value [Object] The value to validate
          # @raise [Treaty::Exceptions::Validation] If value is not a String
          # @return [void]
          def validate_string!(value)
            validate_type!(value, :string) { |v| v.is_a?(String) }
          end

          # Validates that value is a Boolean (TrueClass or FalseClass)
          #
          # @param value [Object] The value to validate
          # @raise [Treaty::Exceptions::Validation] If value is not a Boolean
          # @return [void]
          def validate_boolean!(value)
            validate_type!(value, :boolean) { |v| v.is_a?(TrueClass) || v.is_a?(FalseClass) }
          end

          # Validates that value is a Hash (object type)
          #
          # @param value [Object] The value to validate
          # @raise [Treaty::Exceptions::Validation] If value is not a Hash
          # @return [void]
          def validate_object!(value)
            validate_type!(value, :object) { |v| v.is_a?(Hash) }
          end

          # Validates that value is an Array
          #
          # @param value [Object] The value to validate
          # @raise [Treaty::Exceptions::Validation] If value is not an Array
          # @return [void]
          def validate_array!(value)
            validate_type!(value, :array) { |v| v.is_a?(Array) }
          end

          # Validates that value is a DateTime, Time, or Date
          #
          # @param value [Object] The value to validate
          # @raise [Treaty::Exceptions::Validation] If value is not a datetime type
          # @return [void]
          def validate_datetime!(value)
            # TODO: It is better to divide it into different methods for each class.
            validate_type!(value, :datetime) { |v| v.is_a?(DateTime) || v.is_a?(Time) || v.is_a?(Date) }
          end
        end
      end
    end
  end
end
