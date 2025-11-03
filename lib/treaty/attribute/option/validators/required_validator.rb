# frozen_string_literal: true

module Treaty
  module Attribute
    module Option
      module Validators
        class RequiredValidator < Base
          def validate_schema!
            # Schema structure is already normalized by OptionNormalizer.
            # Nothing to validate here.
          end

          def validate_value!(value)
            return unless required?
            return if present?(value)

            message = option_config.fetch(:message, nil) || default_message

            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation, message
          end

          private

          def required?
            return false if option_config.nil?

            if option_config.is_a?(Hash)
              option_config.fetch(:is, false) == true
            else
              option_config == true
            end
          end

          def present?(value)
            return false if value.nil?
            return false if value.respond_to?(:empty?) && value.empty?

            true
          end

          def default_message
            "Attribute '#{attribute_name}' is required but was not provided or is empty"
          end
        end
      end
    end
  end
end
