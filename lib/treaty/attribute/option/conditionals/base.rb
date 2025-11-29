# frozen_string_literal: true

module Treaty
  module Attribute
    module Option
      module Conditionals
        # Base class for conditional option processors.
        #
        # ## Purpose
        #
        # Conditionals control whether an attribute should be processed at all.
        # Unlike validators (which check data) and modifiers (which transform data),
        # conditionals determine attribute visibility based on runtime conditions.
        #
        # ## Key Difference from Validators/Modifiers
        #
        # - **Validators**: Check if data is valid
        # - **Modifiers**: Transform data values
        # - **Conditionals**: Decide if attribute exists in output
        #
        # ## Processing
        #
        # Conditionals are evaluated BEFORE validators and modifiers:
        # 1. If condition evaluates to `false` → attribute is skipped entirely
        # 2. If condition evaluates to `true` → attribute is processed normally
        #
        # ## Mode Support
        #
        # Conditionals do NOT support simple/advanced modes.
        # They only accept lambda/proc directly:
        #
        # ```ruby
        # # Correct
        # integer :rating, if: ->(**attributes) { attributes.dig(:post, :published_at).present? }
        # array :tags, if: ->(post:) { post[:published_at].present? }
        #
        # # Incorrect - no simple/advanced mode
        # integer :rating, if: true  # Not supported
        # integer :rating, if: { is: ..., message: ... }  # Not supported
        # ```
        #
        # ## Implementation
        #
        # Subclasses must implement:
        # - `validate_schema!` - Validate the conditional schema at definition time
        # - `evaluate_condition(data)` - Evaluate condition with runtime data
        class Base < Treaty::Attribute::Option::Base
          # Phase 1: Validates conditional schema
          # Must be overridden in subclasses
          #
          # @raise [Treaty::Exceptions::Validation] If schema is invalid
          # @return [void]
          def validate_schema!
            raise Treaty::Exceptions::NotImplemented,
                  "#{self.class} must implement #validate_schema!"
          end

          # Evaluates the conditional with runtime data
          # Must be overridden in subclasses
          #
          # @param _data [Hash] Raw data to evaluate condition against
          # @raise [Treaty::Exceptions::Validation] If evaluation fails
          # @return [Boolean] True if attribute should be processed, false otherwise
          def evaluate_condition(_data)
            raise Treaty::Exceptions::NotImplemented,
                  "#{self.class} must implement #evaluate_condition"
          end

          # Conditionals do not validate values
          # This is a no-op for conditionals
          #
          # @param _value [Object] The value (unused)
          # @return [void]
          def validate_value!(_value)
            # No-op: conditionals don't validate values
          end

          # Conditionals do not transform values
          # This is a no-op for conditionals
          #
          # @param value [Object] The value to pass through
          # @return [Object] The unchanged value
          def transform_value(value)
            value
          end
        end
      end
    end
  end
end
