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
                  I18n.t("treaty.attributes.validators.type.unknown_type",
                         type: @attribute_type,
                         attribute: @attribute_name,
                         allowed: ALLOWED_TYPES.join(", "))
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

          # Validates that value is an Integer
          #
          # @param value [Object] The value to validate
          # @raise [Treaty::Exceptions::Validation] If value is not an Integer
          # @return [void]
          def validate_integer!(value)
            return if value.is_a?(Integer)

            raise Treaty::Exceptions::Validation,
                  I18n.t("treaty.attributes.validators.type.mismatch.integer",
                         attribute: @attribute_name,
                         actual: value.class)
          end

          # Validates that value is a String
          #
          # @param value [Object] The value to validate
          # @raise [Treaty::Exceptions::Validation] If value is not a String
          # @return [void]
          def validate_string!(value)
            return if value.is_a?(String)

            raise Treaty::Exceptions::Validation,
                  I18n.t("treaty.attributes.validators.type.mismatch.string",
                         attribute: @attribute_name,
                         actual: value.class)
          end

          # Validates that value is a Boolean (TrueClass or FalseClass)
          #
          # @param value [Object] The value to validate
          # @raise [Treaty::Exceptions::Validation] If value is not a Boolean
          # @return [void]
          def validate_boolean!(value)
            return if value.is_a?(TrueClass) || value.is_a?(FalseClass)

            raise Treaty::Exceptions::Validation,
                  I18n.t("treaty.attributes.validators.type.mismatch.boolean",
                         attribute: @attribute_name,
                         actual: value.class)
          end

          # Validates that value is a Hash (object type)
          #
          # @param value [Object] The value to validate
          # @raise [Treaty::Exceptions::Validation] If value is not a Hash
          # @return [void]
          def validate_object!(value)
            return if value.is_a?(Hash)

            raise Treaty::Exceptions::Validation,
                  I18n.t("treaty.attributes.validators.type.mismatch.object",
                         attribute: @attribute_name,
                         actual: value.class)
          end

          # Validates that value is an Array
          #
          # @param value [Object] The value to validate
          # @raise [Treaty::Exceptions::Validation] If value is not an Array
          # @return [void]
          def validate_array!(value)
            return if value.is_a?(Array)

            raise Treaty::Exceptions::Validation,
                  I18n.t("treaty.attributes.validators.type.mismatch.array",
                         attribute: @attribute_name,
                         actual: value.class)
          end

          # Validates that value is a DateTime, Time, or Date
          #
          # @param value [Object] The value to validate
          # @raise [Treaty::Exceptions::Validation] If value is not a datetime type
          # @return [void]
          def validate_datetime!(value)
            # TODO: It is better to divide it into different methods for each class.
            return if value.is_a?(DateTime) || value.is_a?(Time) || value.is_a?(Date)

            raise Treaty::Exceptions::Validation,
                  I18n.t("treaty.attributes.validators.type.mismatch.datetime",
                         attribute: @attribute_name,
                         actual: value.class)
          end
        end
      end
    end
  end
end
