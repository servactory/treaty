# frozen_string_literal: true

module Treaty
  module Attribute
    module Option
      module Modifiers
        # Converts attribute values between different types automatically.
        #
        # ## Usage Examples
        #
        # Simple mode:
        #   string :created_at, cast: :datetime
        #   datetime :timestamp, cast: :string
        #   integer :active, cast: :boolean
        #
        # Advanced mode with custom error message:
        #   string :created_at, cast: {
        #     to: :datetime,
        #     message: "Invalid date format"
        #   }
        #
        # ## Use Cases
        #
        # 1. **Request type conversion**:
        #    ```ruby
        #    request do
        #      string :created_at, cast: :datetime
        #    end
        #    # Input: { created_at: "2024-01-15T10:30:00Z" }
        #    # Service receives: { created_at: DateTime object }
        #    ```
        #
        # 2. **Response type conversion**:
        #    ```ruby
        #    response 200 do
        #      datetime :created_at, cast: :string
        #    end
        #    # Service returns: { created_at: DateTime object }
        #    # Output: { created_at: "2024-01-15T10:30:00Z" }
        #    ```
        #
        # 3. **Unix timestamp conversion**:
        #    ```ruby
        #    integer :timestamp, cast: :datetime
        #    datetime :created_at, cast: :integer
        #    ```
        #
        # ## Supported Conversions
        #
        # ### From Integer
        # - integer -> string: Converts to string representation
        # - integer -> boolean: 0 = false, non-zero = true
        # - integer -> datetime: Treats as Unix timestamp
        #
        # ### From String
        # - string -> integer: Parses integer from string
        # - string -> boolean: Parses truthy/falsy strings (true/false, yes/no, 1/0, on/off)
        # - string -> datetime: Parses datetime string (ISO8601, RFC3339, etc.)
        #
        # ### From Boolean
        # - boolean -> string: Converts to "true" or "false"
        # - boolean -> integer: true = 1, false = 0
        #
        # ### From DateTime
        # - datetime -> string: Converts to ISO8601 format
        # - datetime -> integer: Converts to Unix timestamp
        #
        # ## Important Notes
        #
        # - Cast option only works with scalar types (integer, string, boolean, datetime)
        # - Array and Object types are not supported for casting
        # - Casting to the same type is allowed (no-op)
        # - Nil values are not transformed (handled by RequiredValidator)
        # - All conversion errors are caught and re-raised as Validation errors
        #
        # ## Error Handling
        #
        # If conversion fails (e.g., invalid date string, non-numeric string to integer),
        # the error is caught and converted to a Treaty::Exceptions::Validation error.
        #
        # ## Advanced Mode
        #
        # Schema format: `{ to: :target_type, message: "Custom error" }`
        # Note: Uses `:to` key instead of the default `:is` key.
        class CastModifier < Treaty::Attribute::Option::Base
          # Types that support casting (scalar types only)
          ALLOWED_CAST_TYPES = %i[integer string boolean datetime].freeze

          # Validates that cast option is correctly configured
          #
          # @raise [Treaty::Exceptions::Validation] If cast configuration is invalid
          # @return [void]
          def validate_schema! # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
            # If option_schema is nil, cast is not used for this attribute
            return if @option_schema.nil?

            target_type = option_value

            # Validate that target type is a Symbol
            unless target_type.is_a?(Symbol)
              raise Treaty::Exceptions::Validation,
                    I18n.t(
                      "treaty.attributes.modifiers.cast.invalid_type",
                      attribute: @attribute_name,
                      type: target_type.class
                    )
            end

            # Validate that source type supports casting
            unless ALLOWED_CAST_TYPES.include?(@attribute_type)
              raise Treaty::Exceptions::Validation,
                    I18n.t(
                      "treaty.attributes.modifiers.cast.source_not_supported",
                      attribute: @attribute_name,
                      source_type: @attribute_type,
                      allowed: ALLOWED_CAST_TYPES.join(", ")
                    )
            end

            # Validate that target type is allowed
            unless ALLOWED_CAST_TYPES.include?(target_type)
              raise Treaty::Exceptions::Validation,
                    I18n.t(
                      "treaty.attributes.modifiers.cast.target_not_supported",
                      attribute: @attribute_name,
                      target_type:,
                      allowed: ALLOWED_CAST_TYPES.join(", ")
                    )
            end

            # Validate that conversion from source to target is supported
            return if conversion_supported?(@attribute_type, target_type)

            raise Treaty::Exceptions::Validation,
                  I18n.t(
                    "treaty.attributes.modifiers.cast.conversion_not_supported",
                    attribute: @attribute_name,
                    from: @attribute_type,
                    to: target_type
                  )
          end

          # Applies type conversion to the value
          # Skips conversion for nil values (handled by RequiredValidator)
          #
          # @param value [Object] The current value
          # @return [Object] Converted value
          def transform_value(value) # rubocop:disable Metrics/MethodLength
            return value if value.nil? # Cast doesn't modify nil, required validator handles it.

            target_type = option_value
            conversion_lambda = conversion_matrix.dig(@attribute_type, target_type)

            # Call conversion lambda
            conversion_lambda.call(value:)
          rescue StandardError => e
            attributes = {
              attribute: @attribute_name,
              from: @attribute_type,
              to: target_type,
              value:,
              error: e.message
            }

            # Catch all exceptions from conversion execution
            error_message = resolve_custom_message(**attributes) || I18n.t(
              "treaty.attributes.modifiers.cast.conversion_error",
              **attributes
            )

            raise Treaty::Exceptions::Validation, error_message
          end

          protected

          # Override value_key to use :to instead of :is
          # This makes advanced mode syntax: cast: { to: :datetime }
          #
          # @return [Symbol] The key :to
          def value_key
            :to
          end

          private

          # Checks if conversion from source type to target type is supported
          #
          # @param from_type [Symbol] Source type
          # @param to_type [Symbol] Target type
          # @return [Boolean] True if conversion is supported
          def conversion_supported?(from_type, to_type)
            conversion_matrix.dig(from_type, to_type).present?
          end

          # Matrix of all supported type conversions
          # Maps from_type => to_type => conversion_lambda
          #
          # @return [Hash] Conversion matrix
          def conversion_matrix # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
            @conversion_matrix ||= {
              integer: {
                integer: ->(value:) { value }, # No-op for same type
                string: ->(value:) { value.to_s },
                boolean: ->(value:) { value != 0 },
                datetime: ->(value:) { Time.at(value) }
              },
              string: {
                string: ->(value:) { value }, # No-op for same type
                integer: ->(value:) { Integer(value) },
                boolean: ->(value:) { parse_boolean(value) },
                datetime: ->(value:) { DateTime.parse(value) }
              },
              boolean: {
                boolean: ->(value:) { value }, # No-op for same type
                string: ->(value:) { value.to_s },
                integer: ->(value:) { value ? 1 : 0 }
              },
              datetime: {
                datetime: ->(value:) { value }, # No-op for same type
                string: ->(value:) { value.iso8601 },
                integer: ->(value:) { value.to_i }
              }
            }
          end

          # Parses a string value into a boolean
          # Recognizes: true/false, yes/no, 1/0, on/off (case-insensitive)
          #
          # @param value [String] The string value to parse
          # @return [Boolean] Parsed boolean value
          # @raise [ArgumentError] If string is not a recognized boolean value
          def parse_boolean(value)
            normalized = value.to_s.downcase.strip

            return true if %w[true 1 yes on].include?(normalized)
            return false if %w[false 0 no off].include?(normalized)

            raise ArgumentError, "Cannot convert '#{value}' to boolean"
          end
        end
      end
    end
  end
end
