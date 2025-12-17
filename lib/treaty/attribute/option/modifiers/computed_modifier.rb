# frozen_string_literal: true

module Treaty
  module Attribute
    module Option
      module Modifiers
        # Computes attribute values from all available raw data.
        #
        # ## Key Difference from Transform
        #
        # - `transform:` receives only `value:` (the current attribute's value)
        # - `computed:` receives `**attributes` (ALL raw data from root level)
        #
        # ## Usage Examples
        #
        # Simple mode:
        #   string :full_name, computed: (lambda do |**attributes|
        #     "#{attributes.dig(:user, :first_name)} #{attributes.dig(:user, :last_name)}"
        #   end)
        #
        # Advanced mode with custom error message:
        #   string :full_name, computed: {
        #     is: ->(**attributes) { "#{attributes.dig(:user, :first_name)} #{attributes.dig(:user, :last_name)}" },
        #     message: "Failed to compute full name"
        #   }
        #
        # ## Use Cases
        #
        # 1. **Derived fields (full name from parts)**:
        #    ```ruby
        #    response 200 do
        #      object :user do
        #        string :first_name
        #        string :last_name
        #        string :full_name, computed: (lambda do |**attributes|
        #          "#{attributes.dig(:user, :first_name)} #{attributes.dig(:user, :last_name)}"
        #        end)
        #      end
        #    end
        #    ```
        #
        # 2. **Calculated values (word count)**:
        #    ```ruby
        #    response 200 do
        #      object :post do
        #        string :content
        #        integer :word_count, computed: (lambda do |**attributes|
        #          attributes.dig(:post, :content).to_s.split.size
        #        end)
        #      end
        #    end
        #    ```
        #
        # 3. **Cross-object computations**:
        #    ```ruby
        #    response 200 do
        #      object :order do
        #        integer :quantity
        #        integer :unit_price
        #        integer :total, computed: (lambda do |**attributes|
        #          attributes.dig(:order, :quantity).to_i * attributes.dig(:order, :unit_price).to_i
        #        end)
        #      end
        #    end
        #    ```
        #
        # ## Important Notes
        #
        # - Lambda must accept `**attributes` (named argument splat)
        # - Receives full raw data from root level (not just current object)
        # - **Always computes** - ignores any existing value, result replaces everything
        # - All exceptions raised in lambda are caught and re-raised as Validation errors
        # - Computation is applied during Phase 3 (transformation phase)
        # - Executes FIRST in modifier chain: computed -> transform -> cast -> default -> as
        #
        # ## Advanced Mode
        #
        # Schema format: `{ is: lambda, message: nil }`
        class ComputedModifier < Treaty::Attribute::Option::Base
          # Validates that computed value is a lambda
          #
          # @raise [Treaty::Exceptions::Validation] If computed is not a Proc/lambda
          # @return [void]
          def validate_schema!
            computed_lambda = option_value

            return if computed_lambda.respond_to?(:call)

            raise Treaty::Exceptions::Validation,
                  I18n.t(
                    "treaty.attributes.modifiers.computed.invalid_type",
                    attribute: @attribute_name,
                    type: computed_lambda.class
                  )
          end

          # Computes value using the provided lambda and full root data
          # Always executes - ignores any existing value
          #
          # @param _value [Object] The current value (ignored - always computes)
          # @param root_data [Hash] Full raw data from root level
          # @return [Object] Computed value
          def transform_value(_value, root_data = {}) # rubocop:disable Metrics/MethodLength
            computed_lambda = option_value

            # Call lambda with full root data as named arguments
            computed_lambda.call(**root_data)
          rescue StandardError => e
            attributes = {
              attribute: @attribute_name,
              error: e.message
            }

            # Catch all exceptions from lambda execution
            error_message = resolve_custom_message(**attributes) || I18n.t(
              "treaty.attributes.modifiers.computed.execution_error",
              **attributes
            )

            raise Treaty::Exceptions::Validation, error_message
          end
        end
      end
    end
  end
end
