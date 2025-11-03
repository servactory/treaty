# frozen_string_literal: true

module Treaty
  module Attribute
    module Option
      module Modifiers
        class AsModifier < Base
          def validate_schema!
            return if option_schema.is_a?(Hash) && option_schema[:is].is_a?(Symbol)
            return if option_schema.is_a?(Symbol)

            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Option 'as' for attribute '#{attribute_name}' must be a Symbol"
          end

          def apply!(value)
            # TODO: It needs to be implemented.

            value
          end
        end
      end
    end
  end
end
