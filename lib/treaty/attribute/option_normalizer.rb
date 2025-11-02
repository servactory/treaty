# frozen_string_literal: true

module Treaty
  module Attribute
    # Normalizes options from simple mode to advanced mode.
    # Simple mode:
    #   {
    #     required: true,
    #     as: :value,
    #     in: %w[twitter linkedin github]
    #   }
    # Advanced mode:
    #   {
    #     required: { is: true, message: nil },
    #     as: { is: :value, message: nil },
    #     inclusion: { in: %w[twitter linkedin github], message: nil }
    #   }
    class OptionNormalizer
      # Maps simple mode option keys to their advanced mode configuration.
      # Format: simple_key => { advanced_key:, value_key: }
      OPTION_KEY_MAPPING = {
        in: { advanced_key: :inclusion, value_key: :in }
      }.freeze
      private_constant :OPTION_KEY_MAPPING

      # Reverse mapping: advanced_key => value_key
      # Used to determine value key when option is already in advanced mode.
      ADVANCED_KEY_TO_VALUE_KEY = OPTION_KEY_MAPPING.each_with_object({}) do |(_, config), result|
        result[config[:advanced_key]] = config[:value_key]
      end.freeze
      private_constant :ADVANCED_KEY_TO_VALUE_KEY

      DEFAULT_VALUE_KEY = :is
      private_constant :DEFAULT_VALUE_KEY

      class << self
        def normalize(options)
          options.each_with_object({}) do |(key, value), result|
            advanced_key, normalized_value = normalize_option(key, value)
            result[advanced_key] = normalized_value
          end
        end

        private

        def normalize_option(key, value) # rubocop:disable Metrics/MethodLength
          mapping = OPTION_KEY_MAPPING[key]

          if mapping.present?
            # Special handling for mapped options (e.g., in -> inclusion).
            advanced_key = mapping[:advanced_key]
            value_key = mapping[:value_key]
            normalized_value = normalize_value(value, value_key)
            [advanced_key, normalized_value]
          else
            # Check if this key is already an advanced mode key.
            value_key = ADVANCED_KEY_TO_VALUE_KEY[key] || DEFAULT_VALUE_KEY
            normalized_value = normalize_value(value, value_key)
            [key, normalized_value]
          end
        end

        def normalize_value(value, value_key)
          if advanced_mode?(value, value_key)
            # Already in advanced mode, ensure it has both keys.
            { value_key => value[value_key], message: value[:message] }
          else
            # Simple mode, convert to advanced.
            # TODO: It is necessary to implement a translation system (I18n).
            { value_key => value, message: nil }
          end
        end

        def advanced_mode?(value, value_key)
          value.is_a?(Hash) && value.key?(value_key)
        end
      end
    end
  end
end
