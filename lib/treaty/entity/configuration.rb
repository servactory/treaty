# frozen_string_literal: true

module Treaty
  class Entity
    # Configuration for Entity processing default options.
    #
    # ## Purpose
    #
    # Manages default options that are applied to all attributes during
    # Entity processing. Allows overriding defaults at call-time while
    # preserving attribute-level explicit options.
    #
    # ## Usage
    #
    # ```ruby
    # # Default required: true (strict validation)
    # config = Configuration.new(required: true)
    #
    # # Default required: false (lenient validation)
    # config = Configuration.new(required: false)
    # ```
    #
    # ## Option Precedence
    #
    # Options are applied with the following precedence (highest to lowest):
    # 1. Explicit attribute options (e.g., `string :name, required: false`)
    # 2. Configuration defaults (e.g., `required: true` from .call)
    # 3. Entity class defaults (e.g., `required: true` for Entity base class)
    #
    # ## Supported Options
    #
    # Currently supported configuration options:
    # - `required:` - Default required behavior for attributes
    #
    # ## Integration
    #
    # Used by Entity.call to pass default options through the processing pipeline:
    #
    # ```ruby
    # # UserEntity.call(data, required: true)
    # config = Configuration.new(required: true)
    # processor = Processor.new(UserEntity, config)
    # result = processor.call(data)
    # ```
    class Configuration
      # List of options that can be configured at call-time
      SUPPORTED_OPTIONS = %i[required].freeze

      # @return [Hash] The configuration options
      attr_reader :options

      # Creates a new Configuration instance.
      #
      # @param options [Hash] Configuration options
      # @option options [Boolean] :required Default required value for attributes
      def initialize(options = {})
        @options = normalize_options(options)
      end

      # Returns the normalized required option.
      #
      # @return [Hash, nil] Normalized required option { is: Boolean, message: nil }
      def required_default
        @options[:required]
      end

      # Checks if required option is set to true.
      #
      # @return [Boolean]
      def required?
        @options.dig(:required, :is) == true
      end

      # Merges configuration options with attribute options.
      # Attribute options take precedence over configuration defaults.
      #
      # @param attribute_options [Hash] Options defined on the attribute
      # @return [Hash] Merged options
      def apply_to(attribute_options)
        result = attribute_options.dup

        # Only apply default if attribute doesn't have explicit required
        unless result.key?(:required)
          result[:required] = required_default if required_default
        end

        result
      end

      # Returns the configuration as a Hash.
      #
      # @return [Hash]
      def to_h
        @options.dup
      end

      # Returns a human-readable representation.
      #
      # @return [String]
      def inspect
        "#<#{self.class.name} @options=#{@options.inspect}>"
      end

      private

      # Normalizes options to the advanced format.
      #
      # Converts simple mode (e.g., `required: true`) to advanced mode
      # (e.g., `required: { is: true, message: nil }`)
      #
      # @param options [Hash] Raw options
      # @return [Hash] Normalized options
      def normalize_options(options)
        result = {}

        if options.key?(:required)
          result[:required] = normalize_required(options[:required])
        end

        result
      end

      # Normalizes the required option.
      #
      # @param value [Boolean, Hash] Required option value
      # @return [Hash] Normalized required option
      def normalize_required(value)
        case value
        when true, false
          { is: value, message: nil }
        when Hash
          { is: value.fetch(:is, true), message: value[:message] }
        else
          { is: true, message: nil }
        end
      end
    end
  end
end
