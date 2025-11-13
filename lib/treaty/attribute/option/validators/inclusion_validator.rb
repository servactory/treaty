# frozen_string_literal: true

module Treaty
  module Attribute
    module Option
      module Validators
        # Validates that attribute value is included in allowed set.
        #
        # ## Usage Examples
        #
        # Simple mode:
        #   string :provider, in: %w[twitter linkedin github]
        #
        # Advanced mode:
        #   string :provider, inclusion: { in: %w[twitter linkedin github], message: "Invalid provider" }
        #
        # ## Advanced Mode
        #
        # Uses `:in` as the value key (instead of default `:is`).
        # Schema format: `{ in: [...], message: nil }`
        class InclusionValidator < Treaty::Attribute::Option::Base
          # Validates that allowed values are provided as non-empty array
          #
          # @raise [Treaty::Exceptions::Validation] If allowed values are not valid
          # @return [void]
          def validate_schema!
            allowed_values = option_value

            return if allowed_values.is_a?(Array) && !allowed_values.empty?

            raise Treaty::Exceptions::Validation,
                  I18n.t(
                    "treaty.attributes.validators.inclusion.invalid_schema",
                    attribute: @attribute_name
                  )
          end

          # Validates that value is included in allowed set
          # Skips validation for nil values (handled by RequiredValidator)
          #
          # @param value [Object] The value to validate
          # @raise [Treaty::Exceptions::Validation] If value is not in allowed set
          # @return [void]
          def validate_value!(value)
            return if value.nil? # Inclusion validation doesn't check for nil, required does.

            allowed_values = option_value

            return if allowed_values.include?(value)

            attributes = {
              attribute: @attribute_name,
              value:,
              allowed_values:
            }

            message = resolve_custom_message(**attributes) || default_message(**attributes)

            raise Treaty::Exceptions::Validation, message
          end

          protected

          # Returns the value key for inclusion validator
          # Uses :in instead of default :is
          #
          # @return [Symbol] The value key (:in)
          def value_key
            :in
          end

          private

          # Generates default error message with allowed values using I18n
          #
          # @param attribute [Symbol] The attribute name
          # @param value [Object] The actual value that failed validation
          # @param allowed_values [Array] Array of allowed values
          # @return [String] Default error message
          def default_message(attribute:, value:, allowed_values:)
            I18n.t(
              "treaty.attributes.validators.inclusion.not_included",
              attribute:,
              allowed: allowed_values.join(", "),
              value:
            )
          end
        end
      end
    end
  end
end
