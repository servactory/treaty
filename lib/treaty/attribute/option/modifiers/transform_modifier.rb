# frozen_string_literal: true

module Treaty
  module Attribute
    module Option
      module Modifiers
        # Transforms attribute values using custom lambda functions.
        #
        # ## Usage Examples
        #
        # Simple mode:
        #   integer :amount, transform: ->(value:) { value * 100 }
        #   string :title, transform: ->(value:) { value.strip.upcase }
        #
        # Advanced mode with custom error message:
        #   integer :amount, transform: {
        #     is: ->(value:) { value * 100 },
        #     message: "Failed to transform amount"
        #   }
        #
        # ## Use Cases
        #
        # 1. **Request transformation**:
        #    ```ruby
        #    request do
        #      integer :amount_cents, transform: ->(value:) { value * 100 }
        #    end
        #    # Input: { amount_cents: 10 }
        #    # Service receives: { amount_cents: 1000 }
        #    ```
        #
        # 2. **Response transformation**:
        #    ```ruby
        #    response 200 do
        #      string :title, transform: ->(value:) { value.titleize }
        #    end
        #    # Service returns: { title: "hello world" }
        #    # Output: { title: "Hello World" }
        #    ```
        #
        # 3. **Complex transformations**:
        #    ```ruby
        #    string :email, transform: ->(value:) { value.downcase.strip }
        #    datetime :timestamp, transform: ->(value:) { value.iso8601 }
        #    ```
        #
        # ## Important Notes
        #
        # - Lambda must accept named argument `value:`
        # - All exceptions raised in lambda are caught and re-raised as Validation errors
        # - Transformation is applied during Phase 3 (after validation)
        # - Can be combined with other options (required, default, as, etc.)
        #
        # ## Error Handling
        #
        # If the lambda raises any exception, it's caught and converted to a
        # Treaty::Exceptions::Validation with appropriate error message.
        #
        # ## Advanced Mode
        #
        # Schema format: `{ is: lambda, message: nil }`
        class TransformModifier < Treaty::Attribute::Option::Base
          # Validates that transform value is a lambda
          #
          # @raise [Treaty::Exceptions::Validation] If transform is not a Proc/lambda
          # @return [void]
          def validate_schema!
            transform_lambda = option_value

            return if transform_lambda.respond_to?(:call)

            raise Treaty::Exceptions::Validation,
                  I18n.t(
                    "treaty.attributes.modifiers.transform.invalid_type",
                    attribute: @attribute_name,
                    type: transform_lambda.class
                  )
          end

          # Applies transformation to the value using the provided lambda
          # Catches all exceptions and re-raises as Validation errors
          #
          # @param value [Object] The current value
          # @return [Object] Transformed value
          def transform_value(value)
            transform_lambda = option_value

            # Call lambda with named argument
            transform_lambda.call(value: value)
          rescue StandardError => e
            # Catch all exceptions from lambda execution
            error_message = resolve_custom_message(
              attribute: @attribute_name,
              error: e.message
            ) || I18n.t(
              "treaty.attributes.modifiers.transform.execution_error",
              attribute: @attribute_name,
              error: e.message
            )

            raise Treaty::Exceptions::Validation, error_message
          end
        end
      end
    end
  end
end
