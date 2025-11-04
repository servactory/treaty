# frozen_string_literal: true

module Treaty
  module Attribute
    module Option
      module Modifiers
        class AsModifier < Base
          def validate_schema!
            return if option_schema.is_a?(Hash) && option_schema.fetch(:is).is_a?(Symbol)
            return if option_schema.is_a?(Symbol)

            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Option 'as' for attribute '#{attribute_name}' must be a Symbol"
          end

          def target_name
            if option_schema.is_a?(Hash)
              option_schema.fetch(:is)
            else
              option_schema
            end
          end

          def apply!(value)
            # AsModifier doesn't modify the value itself, only the name.
            # The renaming is handled by the orchestrator.
            value
          end
        end
      end
    end
  end
end
