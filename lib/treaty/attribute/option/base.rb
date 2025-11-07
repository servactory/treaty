# frozen_string_literal: true

module Treaty
  module Attribute
    module Option
      # Base class for all option processors (validators and modifiers).
      #
      # ## Option Modes
      #
      # Treaty supports two modes for defining options:
      #
      # 1. **Simple Mode** - Concise syntax for common cases:
      #    - `required: true`
      #    - `as: :value`
      #    - `default: 12`
      #    - `in: %w[twitter linkedin]`
      #
      # 2. **Advanced Mode** - Extended syntax with custom messages:
      #    - `required: { is: true, message: "Custom error" }`
      #    - `as: { is: :value, message: nil }`
      #    - `inclusion: { in: %w[...], message: "Must be one of..." }`
      #
      # ## Helpers
      #
      # Helpers are shortcuts in DSL that map to simple mode options:
      # - `:required` → `required: true`
      # - `:optional` → `required: false`
      #
      # ## Advanced Mode Keys
      #
      # Each option in advanced mode has a value key:
      # - Default key: `:is` (used by most options)
      # - Special key: `:in` (used by inclusion validator)
      #
      # The value key is defined by overriding `value_key` method in subclasses.
      #
      # ## Processing Phases
      #
      # Each option processor can participate in three phases:
      # - Phase 1: Schema validation (validate DSL definition correctness)
      # - Phase 2: Value validation (validate runtime data values)
      # - Phase 3: Value transformation (transform values: defaults, renaming, etc.)
      class Base
        # Creates a new option processor instance
        #
        # @param attribute_name [Symbol] The name of the attribute
        # @param attribute_type [Symbol] The type of the attribute
        # @param option_schema [Object] The option schema (simple or advanced mode)
        def initialize(attribute_name:, attribute_type:, option_schema:)
          @attribute_name = attribute_name
          @attribute_type = attribute_type
          @option_schema = option_schema
        end

        # Phase 1: Validates schema (DSL definition)
        # Override in subclasses if validation is needed
        #
        # @raise [Treaty::Exceptions::Validation] If schema is invalid
        # @return [void]
        def validate_schema!
          # No-op by default
        end

        # Phase 2: Validates value (runtime data)
        # Override in subclasses if validation is needed
        #
        # @param value [Object] The value to validate
        # @raise [Treaty::Exceptions::Validation] If value is invalid
        # @return [void]
        def validate_value!(value)
          # No-op by default
        end

        # Phase 3: Transforms value
        # Returns transformed value or original if no transformation needed
        # Override in subclasses if transformation is needed
        #
        # @param value [Object] The value to transform
        # @return [Object] Transformed value
        def transform_value(value)
          value
        end

        # Indicates if this option processor transforms attribute names
        # Override in subclasses if needed (e.g., AsModifier)
        #
        # @return [Boolean] True if this processor transforms names
        def transforms_name?
          false
        end

        # Returns the target name for the attribute if this processor transforms names
        # Override in subclasses if needed (e.g., AsModifier)
        #
        # @return [Symbol] The target attribute name
        def target_name
          @attribute_name
        end

        protected

        # Returns the value key for this option in advanced mode
        # Default is :is, but can be overridden (e.g., :in for inclusion)
        #
        # @return [Symbol] The key used to store the value in advanced mode
        def value_key
          :is
        end

        # Checks if option is enabled
        # Handles both simple mode (boolean) and advanced mode (hash with value key)
        #
        # @return [Boolean] Whether the option is enabled
        def option_enabled?
          return false if @option_schema.nil?
          return @option_schema if @option_schema.is_a?(TrueClass) || @option_schema.is_a?(FalseClass)

          @option_schema.fetch(value_key, false)
        end

        # Extracts the actual value from normalized schema
        # Works with both simple mode and advanced mode
        #
        # In simple mode: returns the value directly
        # In advanced mode: extracts value using the appropriate key (is/in)
        #
        # @return [Object] The actual value from the option schema
        def option_value
          return @option_schema unless @option_schema.is_a?(Hash)

          @option_schema.fetch(value_key, nil)
        end

        # Gets custom error message from advanced mode schema
        # Returns nil if no custom message, which triggers I18n default message
        #
        # @return [String, nil] Custom error message or nil for default message
        def custom_message
          return nil unless @option_schema.is_a?(Hash)

          @option_schema.fetch(:message, nil)
        end

        # Checks if schema is in advanced mode
        #
        # @return [Boolean] True if schema is in advanced mode (hash with value key)
        def advanced_mode?
          @option_schema.is_a?(Hash) && @option_schema.key?(value_key)
        end

        # Checks if schema is in simple mode
        #
        # @return [Boolean] True if schema is in simple mode (not a hash or no value key)
        def simple_mode?
          !advanced_mode?
        end
      end
    end
  end
end
