# frozen_string_literal: true

module Treaty
  module Entity
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
          # - `:date` - Ruby Date
          # - `:time` - Ruby Time
          # - `:datetime` - Ruby DateTime
          #
          # ## Usage Examples
          #
          # Simple types:
          #   integer :age
          #   string :name
          #   boolean :published
          #   date :published_on
          #   time :created_at
          #   datetime :updated_at
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
          # - Date accepts only Date objects (not DateTime or Time)
          # - Time accepts only Time objects (not Date or DateTime)
          # - DateTime accepts only DateTime objects (not Date or Time)
          #
          # ## Note
          #
          # TypeValidator doesn't use option_schema - it validates based on attribute_type.
          # This validator is always active for all attributes.
          class TypeValidator < Treaty::Entity::Attribute::Option::Base # rubocop:disable Metrics/ClassLength
            ALLOWED_TYPES = %i[integer string boolean object array date time datetime].freeze

            # Validates that the attribute type is one of the allowed types
            # and validates type: option if present
            #
            # @raise [Treaty::Exceptions::Validation] If type is not allowed
            # @raise [Treaty::Exceptions::Validation] If type: option is invalid
            # @return [void]
            def validate_schema!
              unless ALLOWED_TYPES.include?(@attribute_type)
                raise Treaty::Exceptions::Validation,
                      I18n.t(
                        "treaty.attributes.validators.type.unknown_type",
                        type: @attribute_type,
                        attribute: @attribute_name,
                        allowed: ALLOWED_TYPES.join(", ")
                      )
              end

              validate_custom_type_schema!
            end

            # Validates that type: option is used correctly
            # Called during schema validation phase
            #
            # @raise [Treaty::Exceptions::Validation] If type: used with non-object attribute
            # @raise [Treaty::Exceptions::Validation] If type: value is not a Class
            # @return [void]
            def validate_custom_type_schema! # rubocop:disable Metrics/MethodLength
              return unless @option_schema

              # type: option only works with object type
              unless @attribute_type == :object
                raise Treaty::Exceptions::Validation,
                      I18n.t(
                        "treaty.attributes.validators.type.option_type_mismatch",
                        attribute: @attribute_name,
                        type: @attribute_type
                      )
              end

              # Validate that value is a Class
              type_value = @option_schema.fetch(:is, nil)
              return if type_value.nil? # No custom type, Hash expected
              return if type_value.is_a?(Class)

              raise Treaty::Exceptions::Validation,
                    I18n.t(
                      "treaty.attributes.validators.type.invalid_class",
                      attribute: @attribute_name,
                      value: type_value.inspect
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
              when :date
                validate_date!(value)
              when :time
                validate_time!(value)
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

            # Validates that value is a Hash or custom type class
            #
            # @param value [Object] The value to validate
            # @raise [Treaty::Exceptions::Validation] If value is not expected type
            # @return [void]
            def validate_object!(value)
              custom_type_class = extract_custom_type_from_schema

              if custom_type_class
                validate_custom_type!(value, custom_type_class)
              else
                validate_type!(value, :object) { |v| v.is_a?(Hash) }
              end
            end

            # Extracts custom type class from option_schema
            # After OptionNormalizer, option_schema is always in advanced mode:
            # { is: User, message: nil }
            #
            # @return [Class, nil] Custom type class or nil
            def extract_custom_type_from_schema
              return nil if @option_schema.nil?

              type_value = @option_schema.fetch(:is, nil)
              type_value.is_a?(Class) ? type_value : nil
            end

            # Validates that value is an instance of custom type class
            #
            # @param value [Object] The value to validate
            # @param expected_class [Class] Expected class
            # @raise [Treaty::Exceptions::Validation] If value is not expected class
            # @return [void]
            def validate_custom_type!(value, expected_class)
              return if value.is_a?(expected_class)

              attributes = {
                attribute: @attribute_name,
                value:,
                type: expected_class.name,
                actual: value.class
              }

              message = resolve_custom_message(**attributes) || default_class_message(**attributes)

              raise Treaty::Exceptions::Validation, message
            end

            # Generates default error message for class type mismatch using I18n
            #
            # @param attribute [Symbol] The attribute name
            # @param type [String] The expected class name
            # @param actual [Class] The actual class of the value
            # @return [String] Default error message
            def default_class_message(attribute:, type:, actual:, **)
              I18n.t(
                "treaty.attributes.validators.type.mismatch.class",
                attribute:,
                type:,
                actual:
              )
            end

            # Validates that value is an Array
            #
            # @param value [Object] The value to validate
            # @raise [Treaty::Exceptions::Validation] If value is not an Array
            # @return [void]
            def validate_array!(value)
              validate_type!(value, :array) { |v| v.is_a?(Array) }
            end

            # Validates that value is a Date (but not DateTime, since DateTime < Date)
            #
            # @param value [Object] The value to validate
            # @raise [Treaty::Exceptions::Validation] If value is not a Date
            # @return [void]
            def validate_date!(value)
              validate_type!(value, :date) { |v| v.is_a?(Date) && !v.is_a?(DateTime) }
            end

            # Validates that value is a Time or ActiveSupport::TimeWithZone
            #
            # @param value [Object] The value to validate
            # @raise [Treaty::Exceptions::Validation] If value is not a Time
            # @return [void]
            def validate_time!(value)
              validate_type!(value, :time) do |v|
                v.is_a?(Time) || (defined?(ActiveSupport::TimeWithZone) && v.is_a?(ActiveSupport::TimeWithZone))
              end
            end

            # Validates that value is a DateTime
            #
            # @param value [Object] The value to validate
            # @raise [Treaty::Exceptions::Validation] If value is not a DateTime
            # @return [void]
            def validate_datetime!(value)
              validate_type!(value, :datetime) { |v| v.is_a?(DateTime) }
            end
          end
        end
      end
    end
  end
end
