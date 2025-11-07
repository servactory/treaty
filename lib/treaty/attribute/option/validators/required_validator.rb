# frozen_string_literal: true

module Treaty
  module Attribute
    module Option
      module Validators
        # Validates that attribute value is present (not nil and not empty).
        #
        # ## Usage Examples
        #
        # Helper mode:
        #   string :title, :required  # Maps to required: true
        #   string :bio, :optional    # Maps to required: false
        #
        # Simple mode:
        #   string :title, required: true
        #   string :bio, required: false
        #
        # Advanced mode:
        #   string :title, required: { is: true, message: "Title is mandatory" }
        #
        # ## Default Behavior
        #
        # - Request attributes: required by default (required: true)
        # - Response attributes: optional by default (required: false)
        #
        # ## Validation Rules
        #
        # A value is considered present if:
        # - It is not nil
        # - It is not empty (for String, Array, Hash)
        #
        # ## Advanced Mode
        #
        # Schema format: `{ is: true/false, message: nil }`
        class RequiredValidator < Treaty::Attribute::Option::Base
          # Validates schema (no validation needed, already normalized)
          #
          # @return [void]
          def validate_schema!
            # Schema structure is already normalized by OptionNormalizer.
            # Nothing to validate here.
          end

          # Validates that required attribute has a present value
          #
          # @param value [Object] The value to validate
          # @raise [Treaty::Exceptions::Validation] If required but value is missing/empty
          # @return [void]
          def validate_value!(value)
            return unless required?
            return if present?(value)

            message = custom_message || default_message

            raise Treaty::Exceptions::Validation, message
          end

          private

          # Checks if attribute is required
          #
          # @return [Boolean] True if attribute is required
          def required?
            return false if @option_schema.nil?

            # Use option_value helper which correctly extracts value based on mode
            option_value == true
          end

          # Checks if value is present (not nil and not empty)
          #
          # @param value [Object] The value to check
          # @return [Boolean] True if value is present
          def present?(value)
            return false if value.nil?
            return false if value.respond_to?(:empty?) && value.empty?

            true
          end

          # Generates default error message using I18n
          #
          # @return [String] Default error message
          def default_message
            I18n.t("treaty.attributes.validators.required.blank", attribute: @attribute_name)
          end
        end
      end
    end
  end
end
