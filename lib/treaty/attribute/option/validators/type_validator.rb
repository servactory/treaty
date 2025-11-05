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
        # - `:object` - Ruby Hash (for nested objects)
        # - `:array` - Ruby Array (for collections)
        # - `:datetime` - Ruby DateTime, Time, or Date
        #
        # ## Usage Examples
        #
        # Simple types:
        #   integer :age
        #   string :name
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
          ALLOWED_TYPES = %i[integer string object array datetime].freeze

          # Validates that the attribute type is one of the allowed types
          #
          # @raise [Treaty::Exceptions::Validation] If type is not allowed
          # @return [void]
          def validate_schema!
            return if ALLOWED_TYPES.include?(@attribute_type)

            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Unknown type '#{@attribute_type}' for attribute '#{@attribute_name}'. " \
                  "Allowed types: #{ALLOWED_TYPES.join(', ')}"
          end

          # Validates that the value matches the declared type
          # Skips validation for nil values (handled by RequiredValidator)
          #
          # @param value [Object] The value to validate
          # @raise [Treaty::Exceptions::Validation] If value type doesn't match
          # @return [void]
          def validate_value!(value) # rubocop:disable Metrics/MethodLength
            return if value.nil? # Type validation doesn't check for nil, required does.

            case @attribute_type
            when :integer
              validate_integer!(value)
            when :string
              validate_string!(value)
            when :object
              validate_object!(value)
            when :array
              validate_array!(value)
            when :datetime
              validate_datetime!(value)
            end
          end

          private

          # Validates that value is an Integer
          #
          # @param value [Object] The value to validate
          # @raise [Treaty::Exceptions::Validation] If value is not an Integer
          # @return [void]
          def validate_integer!(value)
            return if value.is_a?(Integer)

            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Attribute '#{@attribute_name}' must be an Integer, got #{value.class}"
          end

          # Validates that value is a String
          #
          # @param value [Object] The value to validate
          # @raise [Treaty::Exceptions::Validation] If value is not a String
          # @return [void]
          def validate_string!(value)
            return if value.is_a?(String)

            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Attribute '#{@attribute_name}' must be a String, got #{value.class}"
          end

          # Validates that value is a Hash (object type)
          #
          # @param value [Object] The value to validate
          # @raise [Treaty::Exceptions::Validation] If value is not a Hash
          # @return [void]
          def validate_object!(value)
            return if value.is_a?(Hash)

            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Attribute '#{@attribute_name}' must be a Hash (object), got #{value.class}"
          end

          # Validates that value is an Array
          #
          # @param value [Object] The value to validate
          # @raise [Treaty::Exceptions::Validation] If value is not an Array
          # @return [void]
          def validate_array!(value)
            return if value.is_a?(Array)

            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Attribute '#{@attribute_name}' must be an Array, got #{value.class}"
          end

          # Validates that value is a DateTime, Time, or Date
          #
          # @param value [Object] The value to validate
          # @raise [Treaty::Exceptions::Validation] If value is not a datetime type
          # @return [void]
          def validate_datetime!(value)
            # TODO: It is better to divide it into different methods for each class.
            return if value.is_a?(DateTime) || value.is_a?(Time) || value.is_a?(Date)

            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Attribute '#{@attribute_name}' must be a DateTime/Time/Date, got #{value.class}"
          end
        end
      end
    end
  end
end
