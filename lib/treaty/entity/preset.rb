# frozen_string_literal: true

module Treaty
  class Entity
    # Lightweight wrapper for Entity with pre-configured options.
    # Delegates to Callable's private _process/_process! methods via send.
    #
    # ## Design
    #
    # - Stores only options (no processing logic)
    # - Delegates to PRIVATE Callable methods via send
    # - No duplication of Callable logic
    # - preset: is never exposed in public API
    #
    # ## Why send to private methods?
    #
    # Public API methods (call, call!, valid?) don't accept preset:.
    # This avoids confusion if Entity has an attribute named `preset`.
    # Preset uses send to access private _process/_process! methods.
    #
    # ## Usage
    #
    # ```ruby
    # # Create preset
    # preset = UserEntity.preset(required: false)
    #
    # # Delegates to: entity_class.send(:_process, data, preset: self)
    # result = preset.call(data)
    # ```
    #
    # ## Option Precedence
    #
    # Options are applied with the following precedence (highest to lowest):
    # 1. Explicit attribute options (e.g., `string :name, required: false`)
    # 2. Preset options (e.g., `required: true` from .preset())
    # 3. Entity class defaults (e.g., `required: true` for Entity base class)
    class Preset
      # @return [Class<Entity>] The Entity class to process with
      attr_reader :entity_class

      # Creates a new Preset instance.
      #
      # @param entity_class [Class<Entity>] The Entity class to process with
      # @param options [Hash] Configuration options (will be normalized)
      def initialize(entity_class, **options)
        @entity_class = entity_class
        @options = Attribute::OptionNormalizer.normalize(options)
      end

      # Delegates to entity_class's private _process method.
      # Uses send because _process is private.
      # @param arguments [Hash] Data to validate (default: {})
      # @return [Entity::Result] Result object
      def call(arguments = {})
        entity_class.send(:_process, arguments, preset: self)
      end

      # Delegates to entity_class's private _process! method.
      # Uses send because _process! is private.
      # @param arguments [Hash] Data to validate (default: {})
      # @return [Entity::Result] Result object
      # @raise [Treaty::Exceptions::Validation] If validation fails
      def call!(arguments = {})
        entity_class.send(:_process!, arguments, preset: self)
      end

      # Checks if data is valid with preset options.
      # @param arguments [Hash] Data to validate (default: {})
      # @return [Boolean] True if valid
      def valid?(arguments = {})
        call(arguments).valid?
      end

      # Returns true if any options are configured.
      #
      # @return [Boolean]
      def any?
        @options.any?
      end

      # Merges preset options with attribute options.
      # Explicit attribute options take precedence over preset defaults.
      #
      # @param attribute_options [Hash] Options defined on the attribute
      # @param explicit_options [Set<Symbol>] Set of explicitly defined option names
      # @return [Hash] Merged options
      def merge_with(attribute_options, explicit_options)
        return attribute_options if @options.empty?

        result = attribute_options.dup
        @options.each do |option_name, value|
          # Skip if attribute explicitly defined this option
          next if explicit_options.include?(option_name)

          result[option_name] = value
        end
        result
      end

      # Returns the preset as a Hash.
      #
      # @return [Hash]
      def to_h
        @options.dup
      end

      # Returns a human-readable representation.
      #
      # @return [String]
      def inspect
        "#<#{self.class.name} entity_class=#{entity_class.name} options=#{@options.keys.inspect}>"
      end
    end
  end
end
