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
        # - integer -> date: Treats as Unix timestamp, converts to date
        # - integer -> time: Treats as Unix timestamp
        # - integer -> datetime: Treats as Unix timestamp, converts to datetime
        #
        # ### From String
        # - string -> integer: Parses integer from string
        # - string -> boolean: Parses truthy/falsy strings (true/false, yes/no, 1/0, on/off)
        # - string -> date: Parses date string
        # - string -> time: Parses time string
        # - string -> datetime: Parses datetime string (ISO8601, RFC3339, etc.)
        #
        # ### From Boolean
        # - boolean -> string: Converts to "true" or "false"
        # - boolean -> integer: true = 1, false = 0
        #
        # ### From Date
        # - date -> string: Converts to ISO8601 format
        # - date -> integer: Converts to Unix timestamp
        # - date -> time: Converts to Time at midnight
        # - date -> datetime: Converts to DateTime at midnight
        #
        # ### From Time
        # - time -> string: Converts to ISO8601 format
        # - time -> integer: Converts to Unix timestamp
        # - time -> date: Converts to Date
        # - time -> datetime: Converts to DateTime
        #
        # ### From DateTime
        # - datetime -> string: Converts to ISO8601 format
        # - datetime -> integer: Converts to Unix timestamp
        # - datetime -> date: Converts to Date
        # - datetime -> time: Converts to Time
        #
        # ## Important Notes
        #
        # - Cast option only works with scalar types (integer, string, boolean, date, time, datetime)
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
        class CastModifier < Treaty::Attribute::Option::Base # rubocop:disable Metrics/ClassLength
          # Types that support casting (scalar types only)
          ALLOWED_CAST_TYPES = %i[integer string boolean date time datetime].freeze

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
          # @param _root_data [Hash] Unused root data parameter
          # @return [Object] Converted value
          def transform_value(value, _root_data = {}) # rubocop:disable Metrics/MethodLength
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
                date: ->(value:) { Time.at(value).to_date },
                time: ->(value:) { Time.at(value) },
                datetime: ->(value:) { Time.at(value).to_datetime }
              },
              string: {
                string: ->(value:) { value }, # No-op for same type
                integer: ->(value:) { Integer(value) },
                boolean: ->(value:) { parse_boolean(value) },
                date: ->(value:) { Date.parse(value) },
                time: ->(value:) { Time.parse(value) },
                datetime: ->(value:) { DateTime.parse(value) }
              },
              boolean: {
                boolean: ->(value:) { value }, # No-op for same type
                string: ->(value:) { value.to_s },
                integer: ->(value:) { value ? 1 : 0 }
              },
              date: {
                date: ->(value:) { value }, # No-op for same type
                string: ->(value:) { value.iso8601 },
                integer: ->(value:) { value.to_time.to_i },
                time: ->(value:) { value.to_time },
                datetime: ->(value:) { value.to_datetime }
              },
              time: {
                time: ->(value:) { value }, # No-op for same type
                string: ->(value:) { value.iso8601 },
                integer: ->(value:) { value.to_i },
                date: ->(value:) { value.to_date },
                datetime: ->(value:) { value.to_datetime }
              },
              datetime: {
                datetime: ->(value:) { value }, # No-op for same type
                string: ->(value:) { value.iso8601 },
                integer: ->(value:) { value.to_i },
                date: ->(value:) { value.to_date },
                time: ->(value:) { value.to_time }
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
