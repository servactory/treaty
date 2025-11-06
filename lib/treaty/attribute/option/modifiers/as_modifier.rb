# frozen_string_literal: true

module Treaty
  module Attribute
    module Option
      module Modifiers
        # Transforms attribute names during data processing.
        #
        # ## Usage Examples
        #
        # Simple mode:
        #   # Request: expects "handle", outputs as "value"
        #   string :handle, as: :value
        #
        # Advanced mode:
        #   string :handle, as: { is: :value, message: nil }
        #
        # ## Use Cases
        #
        # 1. **Request to Service mapping**:
        #    ```ruby
        #    request do
        #      string :user_id, as: :id
        #    end
        #    # Input: { user_id: "123" }
        #    # Service receives: { id: "123" }
        #    ```
        #
        # 2. **Service to Response mapping**:
        #    ```ruby
        #    response 200 do
        #      string :id, as: :user_id
        #    end
        #    # Service returns: { id: "123" }
        #    # Output: { user_id: "123" }
        #    ```
        #
        # ## How It Works
        #
        # AsModifier doesn't transform values - it transforms attribute names.
        # The orchestrator uses `target_name` to map source name to target name.
        #
        # ## Advanced Mode
        #
        # Schema format: `{ is: :symbol, message: nil }`
        class AsModifier < Treaty::Attribute::Option::Base
          # Validates that target name is a Symbol
          #
          # @raise [Treaty::Exceptions::Validation] If target is not a Symbol
          # @return [void]
          def validate_schema!
            target = option_value

            return if target.is_a?(Symbol)

            raise Treaty::Exceptions::Validation,
                  I18n.t("treaty.attributes.modifiers.as.invalid_type",
                         attribute: @attribute_name,
                         type: target.class)
          end

          # Indicates that AsModifier transforms attribute names
          #
          # @return [Boolean] Always returns true
          def transforms_name?
            true
          end

          # Returns the target name for the attribute
          #
          # @return [Symbol] The target attribute name
          def target_name
            option_value
          end

          # AsModifier doesn't modify the value itself, only the name
          # The renaming is handled by the orchestrator using target_name
          #
          # @param value [Object] The value to transform
          # @return [Object] Unchanged value
          def transform_value(value)
            value
          end
        end
      end
    end
  end
end
