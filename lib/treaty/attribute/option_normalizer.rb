# frozen_string_literal: true

module Treaty
  module Attribute
    # Normalizes options from simple mode to advanced mode.
    #
    # ## Purpose
    #
    # All options are stored and processed internally in advanced mode.
    # This normalizer converts simple mode to advanced mode automatically.
    #
    # ## Modes Explained
    #
    # ### Simple Mode (Concise syntax)
    # ```ruby
    # {
    #   required: true,
    #   as: :value,
    #   in: %w[twitter linkedin github],
    #   default: 12
    # }
    # ```
    #
    # ### Advanced Mode (With messages)
    # ```ruby
    # {
    #   required: { is: true, message: nil },
    #   as: { is: :value, message: nil },
    #   inclusion: { in: %w[twitter linkedin github], message: nil },
    #   default: { is: 12, message: nil }
    # }
    # ```
    #
    # ## Key Mappings
    #
    # Some simple mode keys are renamed in advanced mode:
    # - `in:` → `inclusion:` (with value key `:in`)
    #
    # Others keep the same name:
    # - `required:` → `required:` (with value key `:is`)
    # - `as:` → `as:` (with value key `:is`)
    # - `default:` → `default:` (with value key `:is`)
    #
    # ## Value Keys
    #
    # Each option has a value key in advanced mode:
    # - Default: `:is` (most options)
    # - Special: `:in` (inclusion validator)
    #
    # ## Message Field
    #
    # The `message` field in advanced mode allows custom error messages:
    # - `nil` - Use default message (most common)
    # - String - Custom error message for validation failures
    #
    # ## Usage in DSL
    #
    # Users can write in either mode:
    #
    # Simple mode:
    #   string :provider, in: %w[twitter linkedin]
    #
    # Advanced mode:
    #   string :provider, inclusion: { in: %w[twitter linkedin], message: "Invalid provider" }
    #
    # Both are normalized to advanced mode internally.
    class OptionNormalizer
      # Maps simple mode option keys to their advanced mode configuration.
      # Format: simple_key => { advanced_key:, value_key: }
      OPTION_KEY_MAPPING = {
        in: { advanced_key: :inclusion, value_key: :in },
        as: { advanced_key: :as, value_key: :is },
        default: { advanced_key: :default, value_key: :is }
      }.freeze
      private_constant :OPTION_KEY_MAPPING

      # Reverse mapping: advanced_key => value_key
      # Used to determine value key when option is already in advanced mode.
      ADVANCED_KEY_TO_VALUE_KEY = OPTION_KEY_MAPPING.each_with_object({}) do |(_, config), result|
        result[config.fetch(:advanced_key)] = config.fetch(:value_key)
      end.freeze
      private_constant :ADVANCED_KEY_TO_VALUE_KEY

      DEFAULT_VALUE_KEY = :is
      private_constant :DEFAULT_VALUE_KEY

      class << self
        # Normalizes all options from simple mode to advanced mode
        #
        # @param options [Hash] Options hash in simple or advanced mode
        # @return [Hash] Normalized options in advanced mode
        def normalize(options)
          options.each_with_object({}) do |(key, value), result|
            advanced_key, normalized_value = normalize_option(key, value)
            result[advanced_key] = normalized_value
          end
        end

        private

        # Normalizes a single option to advanced mode
        #
        # @param key [Symbol] Option key
        # @param value [Object] Option value
        # @return [Array<Symbol, Hash>] Tuple of [advanced_key, normalized_value]
        def normalize_option(key, value) # rubocop:disable Metrics/MethodLength
          mapping = OPTION_KEY_MAPPING.fetch(key, nil)

          if mapping.present?
            # Special handling for mapped options (e.g., in -> inclusion).
            advanced_key = mapping.fetch(:advanced_key)
            value_key = mapping.fetch(:value_key)
            normalized_value = normalize_value(value, value_key)
            [advanced_key, normalized_value]
          else
            # Check if this key is already an advanced mode key.
            value_key = ADVANCED_KEY_TO_VALUE_KEY.fetch(key, nil) || DEFAULT_VALUE_KEY
            normalized_value = normalize_value(value, value_key)
            [key, normalized_value]
          end
        end

        # Normalizes option value to advanced mode format
        #
        # @param value [Object] The option value (simple or advanced mode)
        # @param value_key [Symbol] The key to use for the value (:is or :in)
        # @return [Hash] Normalized hash with value_key and :message
        def normalize_value(value, value_key)
          if advanced_mode?(value, value_key)
            # Already in advanced mode, ensure it has both keys.
            # message: nil means use I18n default message from validators
            { value_key => value.fetch(value_key), message: value.fetch(:message, nil) }
          else
            # Simple mode, convert to advanced.
            # message: nil means use I18n default message from validators
            { value_key => value, message: nil }
          end
        end

        # Checks if value is already in advanced mode
        #
        # @param value [Object] The value to check
        # @param value_key [Symbol] The expected value key
        # @return [Boolean] True if value is a hash with the value key
        def advanced_mode?(value, value_key)
          value.is_a?(Hash) && value.key?(value_key)
        end
      end
    end
  end
end
