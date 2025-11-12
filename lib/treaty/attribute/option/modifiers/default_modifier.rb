# frozen_string_literal: true

module Treaty
  module Attribute
    module Option
      module Modifiers
        # Sets default values for attributes when value is nil.
        #
        # ## Usage Examples
        #
        # Simple mode with static value:
        #   integer :limit, default: 12
        #   string :status, default: "pending"
        #   boolean :active, default: false
        #
        # Simple mode with dynamic value (Proc):
        #   datetime :created_at, default: -> { Time.current }
        #   string :uuid, default: -> { SecureRandom.uuid }
        #
        # Advanced mode:
        #   integer :limit, default: { is: 12, message: nil }
        #
        # ## Use Cases
        #
        # 1. **Response defaults** (most common):
        #    ```ruby
        #    response 200 do
        #      object :meta do
        #        integer :limit, default: 12
        #        integer :page, default: 1
        #      end
        #    end
        #    # Service returns: { meta: { page: 1 } }
        #    # Output: { meta: { page: 1, limit: 12 } }
        #    ```
        #
        # 2. **Request defaults**:
        #    ```ruby
        #    request do
        #      string :format, default: "json"
        #    end
        #    # Input: {}
        #    # Service receives: { format: "json" }
        #    ```
        #
        # ## Important Notes
        #
        # - Default is applied ONLY when value is nil
        # - Empty strings, empty arrays, false are NOT replaced
        # - Proc defaults are called at transformation time
        # - Procs receive no arguments
        #
        # ## Array and Object Types
        #
        # NOTE: DO NOT use `default: []` or `default: {}` for array/object types!
        # Array and object types automatically represent empty collections.
        #
        # Incorrect:
        #   array :tags, default: []      # Wrong! Redundant
        #   object :meta, default: {}     # Wrong! Redundant
        #
        # Correct:
        #   array :tags                   # Automatically handles empty array
        #   object :meta                  # Automatically handles empty object
        #
        # ## Advanced Mode
        #
        # Schema format: `{ is: value_or_proc, message: nil }`
        class DefaultModifier < Treaty::Attribute::Option::Base
          # Validates schema (no validation needed)
          # Default value can be any type
          #
          # @return [void]
          def validate_schema!
            # Schema structure is already normalized by OptionNormalizer.
            # Default value can be any type, so nothing specific to validate here.
          end

          # Applies default value if current value is nil
          # Empty strings, empty arrays, and false are NOT replaced
          #
          # @param value [Object] The current value
          # @param _context [Hash] Unused context parameter
          # @return [Object] Default value if original is nil, otherwise original value
          def transform_value(value, _context = {})
            # Only apply default if value is nil
            # Empty strings, empty arrays, false are NOT replaced
            return value unless value.nil?

            default_value = option_value

            # If default value is a Proc, call it to get the value
            if default_value.is_a?(Proc)
              default_value.call
            else
              default_value
            end
          end
        end
      end
    end
  end
end
