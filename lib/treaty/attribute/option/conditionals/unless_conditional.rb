# frozen_string_literal: true

module Treaty
  module Attribute
    module Option
      module Conditionals
        # Conditionally excludes attributes based on runtime data evaluation.
        #
        # ## Usage Examples
        #
        # Basic usage with keyword arguments splat:
        #   array :tags, unless: ->(**attributes) { attributes.dig(:post, :published_at).present? }
        #   integer :draft_views, unless: ->(**attributes) { attributes.dig(:post, :published_at).present? }
        #
        # Named argument pattern:
        #   array :draft_notes, unless: ->(post:) { post[:published_at].present? }
        #   integer :edit_count, unless: ->(post:) { post[:published_at].present? }
        #
        # Complex conditions:
        #   string :internal_note, unless: (lambda do |**attributes|
        #     attributes.dig(:user, :role) == "admin" && attributes.dig(:post, :flagged)
        #   end)
        #
        # ## Use Cases
        #
        # 1. **Hide fields when published**:
        #    ```ruby
        #    response 200 do
        #      object :post do
        #        string :id
        #        string :title
        #        datetime :published_at, :optional
        #        integer :draft_views, unless: ->(**attributes) { attributes.dig(:post, :published_at).present? }
        #      end
        #    end
        #    # If published_at is nil → draft_views is included in response
        #    # If published_at exists → draft_views is excluded
        #    ```
        #
        # 2. **Role-based field exclusion**:
        #    ```ruby
        #    response 200 do
        #      object :user do
        #        string :name
        #        string :internal_id, unless: ->(user:) { user[:role] == "public" }
        #      end
        #    end
        #    ```
        #
        # 3. **Nested attribute conditionals**:
        #    ```ruby
        #    object :post do
        #      string :title
        #      array :draft_notes, unless: ->(post:) { post[:published_at].present? } do
        #        string :_self
        #      end
        #    end
        #    ```
        #
        # ## Important Notes
        #
        # - Lambda receives raw data as named arguments
        # - Lambda MUST return truthy/falsy value
        # - If condition is true → attribute is completely omitted (OPPOSITE of `if`)
        # - If condition is false → attribute is validated and transformed normally
        # - All exceptions in lambda are caught and wrapped in Treaty::Exceptions::Validation
        # - Does NOT support simple mode (unless: true) or advanced mode (unless: { is: ..., message: ... })
        #
        # ## Difference from `if` Option
        #
        # `unless` is the logical opposite of `if`:
        # - `if` includes attribute when condition is TRUE
        # - `unless` includes attribute when condition is FALSE
        #
        # ```ruby
        # # These are equivalent:
        # integer :rating, if: ->(**attributes) { attributes.dig(:post, :published_at).present? }
        # integer :rating, unless: ->(**attributes) { attributes.dig(:post, :published_at).blank? }
        #
        # # These are also equivalent:
        # integer :draft_views, unless: ->(**attributes) { attributes.dig(:post, :published_at).present? }
        # integer :draft_views, if: ->(**attributes) { attributes.dig(:post, :published_at).blank? }
        # ```
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
        # integer :draft_views, unless: ->(**attributes) { attributes.dig(:post, :published_at).present? }
        #
        # # Alternative: named argument pattern
        # integer :draft_views, unless: ->(post:) { post[:published_at].present? }
        # ```
        class UnlessConditional < Treaty::Attribute::Option::Conditionals::Base
          # Validates that unless option is a callable (Proc/Lambda)
          #
          # @raise [Treaty::Exceptions::Validation] If unless is not a Proc/lambda
          # @return [void]
          def validate_schema!
            conditional_lambda = @option_schema

            return if conditional_lambda.respond_to?(:call)

            raise Treaty::Exceptions::Validation,
                  I18n.t(
                    "treaty.attributes.conditionals.unless.invalid_type",
                    attribute: @attribute_name,
                    type: conditional_lambda.class
                  )
          end

          # Evaluates the conditional lambda with runtime data
          # Returns boolean indicating if attribute should be processed
          #
          # @param data [Hash] Raw data from request/response/entity
          # @raise [Treaty::Exceptions::Validation] If lambda execution fails
          # @return [Boolean] True if attribute should be processed (when condition is FALSE), false to skip it
          def evaluate_condition(data)
            conditional_lambda = @option_schema

            # Call lambda with raw data as named arguments
            # The lambda can use **attributes or specific named args like post:
            result = conditional_lambda.call(**data)

            # Convert result to boolean and NEGATE it (opposite of if)
            # unless includes attribute when condition is FALSE
            !result
          rescue StandardError => e
            # Catch all exceptions from lambda execution
            raise Treaty::Exceptions::Validation,
                  I18n.t(
                    "treaty.attributes.conditionals.unless.evaluation_error",
                    attribute: @attribute_name,
                    error: e.message
                  )
          end
        end
      end
    end
  end
end
