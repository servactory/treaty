# frozen_string_literal: true

module Treaty
  module Attribute
    module Option
      module Validators
        # Validates that string attribute value matches a specific format.
        #
        # ## Supported Formats
        #
        # - `:uuid` - Universally unique identifier
        # - `:email` - Email address (RFC 2822 compliant)
        # - `:password` - Password (8-16 chars, must contain digit, lowercase, and uppercase)
        # - `:duration` - ActiveSupport::Duration compatible string (e.g., "1 day", "2 hours")
        # - `:date` - ISO 8601 date string (e.g., "2025-01-15")
        # - `:datetime` - ISO 8601 datetime string (e.g., "2025-01-15T10:30:00Z")
        # - `:time` - Time string (e.g., "10:30:00", "10:30 AM")
        # - `:boolean` - Boolean string ("true", "false", "0", "1")
        #
        # ## Usage Examples
        #
        # Simple mode:
        #   string :email, format: :email
        #   string :started_on, format: :date
        #
        # Advanced mode:
        #   string :email, format: { is: :email }
        #   string :started_on, format: { is: :date, message: "Invalid date format" }
        #   string :started_on, format: { is: :date, message: ->(attribute:, value:, **) { "#{attribute} has invalid date: #{value}" } } # rubocop:disable Layout/LineLength
        #
        # ## Validation Rules
        #
        # - Only works with `:string` type attributes
        # - Raises Treaty::Exceptions::Validation if used with non-string types
        # - Skips validation for nil values (handled by RequiredValidator)
        # - Each format has a pattern and/or validator for flexible validation
        #
        # ## Extensibility
        #
        # To add new formats, extend DEFAULT_FORMATS hash with format definition:
        #   DEFAULT_FORMATS[:custom_format] = {
        #     pattern: /regex/,
        #     validator: ->(value) { custom_validation_logic }
        #   }
        class FormatValidator < Treaty::Attribute::Option::Base # rubocop:disable Metrics/ClassLength
          # UUID format regex (8-4-4-4-12 hexadecimal pattern)
          UUID_PATTERN = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i

          # Password format regex (8-16 chars, at least one digit, lowercase, and uppercase)
          PASSWORD_PATTERN = /\A(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).{8,16}\z/

          # Boolean string format regex (accepts "true", "false", "0", "1" case-insensitive)
          BOOLEAN_PATTERN = /\A(true|false|0|1)\z/i

          # Default format definitions with patterns and validators
          # Each format can have:
          # - pattern: Regex for pattern matching
          # - validator: Lambda for custom validation logic
          DEFAULT_FORMATS = {
            uuid: {
              pattern: UUID_PATTERN,
              validator: nil
            },
            email: {
              pattern: URI::MailTo::EMAIL_REGEXP,
              validator: nil
            },
            password: {
              pattern: PASSWORD_PATTERN,
              validator: nil
            },
            duration: {
              pattern: nil,
              validator: lambda do |value|
                ActiveSupport::Duration.parse(value)
                true
              rescue StandardError
                false
              end
            },
            date: {
              pattern: nil,
              validator: lambda do |value|
                Date.parse(value)
                true
              rescue ArgumentError, TypeError
                false
              end
            },
            datetime: {
              pattern: nil,
              validator: lambda do |value|
                DateTime.parse(value)
                true
              rescue ArgumentError, TypeError
                false
              end
            },
            time: {
              pattern: nil,
              validator: lambda do |value|
                Time.parse(value)
                true
              rescue ArgumentError, TypeError
                false
              end
            },
            boolean: {
              pattern: BOOLEAN_PATTERN,
              validator: nil
            }
          }.freeze

          # Validates that format is only used with string type attributes
          # and that the format name is valid
          #
          # @raise [Treaty::Exceptions::Validation] If format is used with non-string type
          # @raise [Treaty::Exceptions::Validation] If format name is unknown
          # @return [void]
          def validate_schema! # rubocop:disable Metrics/MethodLength
            # Format option only works with string types
            unless @attribute_type == :string
              raise Treaty::Exceptions::Validation,
                    I18n.t(
                      "treaty.attributes.validators.format.type_mismatch",
                      attribute: @attribute_name,
                      type: @attribute_type
                    )
            end

            format_name = option_value

            # Validate that format name exists
            return if formats.key?(format_name)

            raise Treaty::Exceptions::Validation,
                  I18n.t(
                    "treaty.attributes.validators.format.unknown_format",
                    attribute: @attribute_name,
                    format_name:,
                    allowed: formats.keys.join(", ")
                  )
          end

          # Validates that the value matches the specified format
          # Skips validation for nil values (handled by RequiredValidator)
          #
          # @param value [String] The value to validate
          # @raise [Treaty::Exceptions::Validation] If value doesn't match format
          # @return [void]
          def validate_value!(value) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
            return if value.nil? # Format validation doesn't check for nil, required does.

            format_name = option_value
            format_definition = formats[format_name]

            # Allow blank values (empty strings should be caught by required validator)
            return if value.to_s.strip.empty?

            # Apply pattern matching if defined
            if format_definition.fetch(:pattern)
              return if value.match?(format_definition.fetch(:pattern))

              # Pattern failed, and no validator - raise error
              unless format_definition.fetch(:validator)
                attributes = {
                  attribute: @attribute_name,
                  value:,
                  format_name:
                }

                message = resolve_custom_message(**attributes) || default_message(**attributes)

                raise Treaty::Exceptions::Validation, message
              end
            end

            # Apply validator if defined
            return unless format_definition.fetch(:validator)
            return if format_definition.fetch(:validator).call(value)

            attributes = {
              attribute: @attribute_name,
              value:,
              format_name:
            }

            message = resolve_custom_message(**attributes) || default_message(**attributes)

            raise Treaty::Exceptions::Validation, message
          end

          private

          # Returns the available formats (allows for extension)
          #
          # @return [Hash] Hash of available formats with their definitions
          def formats
            DEFAULT_FORMATS
          end

          # Generates default error message for format validation failure using I18n
          #
          # @param attribute [Symbol] The attribute name
          # @param value [Object] The actual value that failed validation
          # @param format_name [Symbol] The format name
          # @return [String] Default error message
          def default_message(attribute:, value:, format_name:)
            I18n.t(
              "treaty.attributes.validators.format.mismatch",
              attribute:,
              value:,
              format_name:
            )
          end
        end
      end
    end
  end
end
