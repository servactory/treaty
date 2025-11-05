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

            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Option 'inclusion' for attribute '#{@attribute_name}' must have a non-empty array of allowed values"
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

            message = custom_message || default_message(allowed_values, value)

            # TODO: It is necessary to implement a translation system (I18n).
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

          # Generates default error message with allowed values
          #
          # @param allowed_values [Array] Array of allowed values
          # @param value [Object] The actual value that failed validation
          # @return [String] Default error message
          def default_message(allowed_values, value)
            # TODO: It is necessary to implement a translation system (I18n).
            "Attribute '#{@attribute_name}' must be one of: #{allowed_values.join(', ')}. Got: '#{value}'"
          end
        end
      end
    end
  end
end
