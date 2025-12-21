# frozen_string_literal: true

module Treaty
  class Entity
    module Attribute
      module Option
        module Conditionals
          # Conditionally includes attributes based on runtime data evaluation.
          #
          # ## Usage Examples
          #
          # Basic usage with keyword arguments splat:
          #   array :tags, if: ->(**attributes) { attributes.dig(:post, :published_at).present? }
          #   integer :rating, if: ->(**attributes) { attributes.dig(:post, :published_at).present? }
          #
          # Named argument pattern:
          #   array :tags, if: ->(post:) { post[:published_at].present? }
          #   integer :views, if: ->(post:) { post[:published_at].present? }
          #
          # Complex conditions:
          #   string :admin_note, if: (lambda do |**attributes|
          #     attributes.dig(:user, :role) == "admin" && attributes.dig(:post, :flagged)
          #   end)
          #
          # ## Use Cases
          #
          # 1. **Show fields only when published**:
          #    ```ruby
          #    response 200 do
          #      object :post do
          #        string :id
          #        string :title
          #        datetime :published_at, :optional
          #        integer :rating, if: ->(**attributes) { attributes.dig(:post, :published_at).present? }
          #      end
          #    end
          #    # If published_at is nil → rating is excluded from response
          #    # If published_at exists → rating is included
          #    ```
          #
          # 2. **Role-based field visibility**:
          #    ```ruby
          #    response 200 do
          #      object :user do
          #        string :name
          #        string :email, if: ->(user:) { user[:role] == "admin" }
          #      end
          #    end
          #    ```
          #
          # 3. **Nested attribute conditionals**:
          #    ```ruby
          #    object :post do
          #      string :title
          #      array :tags, if: ->(post:) { post[:published_at].present? } do
          #        string :_self
          #      end
          #    end
          #    ```
          #
          # ## Important Notes
          #
          # - Lambda receives raw data as named arguments
          # - Lambda MUST return truthy/falsy value
          # - If condition is false → attribute is completely omitted
          # - If condition is true → attribute is validated and transformed normally
          # - All exceptions in lambda are caught and wrapped in Treaty::Exceptions::Validation
          # - Does NOT support simple mode (if: true) or advanced mode (if: { is: ..., message: ... })
          #
          # ## Error Handling
          #
          # If the lambda raises any exception, it's caught and converted to a
          # Treaty::Exceptions::Validation with detailed error message including:
          # - Attribute name
          # - Original exception message
          #
          # ## Data Access Pattern
          #
          # The lambda receives the same data structure that the orchestrator processes.
          # For nested attributes, you can access parent data using dig:
          #
          # ```ruby
          # # For response with { post: { title: "...", published_at: "..." } }
          # integer :rating, if: ->(**attributes) { attributes.dig(:post, :published_at).present? }
          #
          # # Alternative: named argument pattern
          # integer :rating, if: ->(post:) { post[:published_at].present? }
          # ```
          class IfConditional < Treaty::Entity::Attribute::Option::Conditionals::Base
            # Validates that if option is a callable (Proc/Lambda)
            #
            # @raise [Treaty::Exceptions::Validation] If if is not a Proc/lambda
            # @return [void]
            def validate_schema!
              conditional_lambda = @option_schema

              return if conditional_lambda.respond_to?(:call)

              raise Treaty::Exceptions::Validation,
                    I18n.t(
                      "treaty.attributes.conditionals.if.invalid_type",
                      attribute: @attribute_name,
                      type: conditional_lambda.class
                    )
            end

            # Evaluates the conditional lambda with runtime data
            # Returns boolean indicating if attribute should be processed
            #
            # @param data [Hash] Raw data from request/response/entity
            # @raise [Treaty::Exceptions::Validation] If lambda execution fails
            # @return [Boolean] True if attribute should be processed, false to skip it
            def evaluate_condition(data)
              conditional_lambda = @option_schema

              # Call lambda with raw data as named arguments
              # The lambda can use **attributes or specific named args like post:
              result = conditional_lambda.call(**data)

              # Convert result to boolean
              !!result
            rescue StandardError => e
              # Catch all exceptions from lambda execution
              raise Treaty::Exceptions::Validation,
                    I18n.t(
                      "treaty.attributes.conditionals.if.evaluation_error",
                      attribute: @attribute_name,
                      error: e.message
                    )
            end
          end
        end
      end
    end
  end
end
