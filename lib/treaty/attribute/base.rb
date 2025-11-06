# frozen_string_literal: true

module Treaty
  module Attribute
    # Base class for all attribute definitions in Treaty DSL.
    #
    # ## Purpose
    #
    # Represents a single attribute defined in request/response scopes.
    # Handles:
    # - Attribute metadata (name, type, nesting level)
    # - Helper mode to simple mode conversion
    # - Simple mode to advanced mode normalization
    # - Nested attributes (for object and array types)
    #
    # ## Usage
    #
    # Attributes are created through DSL methods:
    #   string :title, :required
    #   integer :age, default: 18
    #   object :author do
    #     string :name
    #   end
    #
    # ## Processing Flow
    #
    # 1. Extract helpers from arguments (`:required`, `:optional`)
    # 2. Convert helpers to simple mode options
    # 3. Merge with explicit options
    # 4. Normalize all options to advanced mode
    # 5. Apply defaults (required: true for request, false for response)
    # 6. Process nested attributes if block given
    #
    # ## Nested Attributes
    #
    # Object and array types can have nested attributes:
    # - `object` - nested attributes as direct children
    # - `array` - nested attributes define array element structure
    #
    # Special scope `:_self` is used for simple arrays:
    #   array :tags do
    #     string :_self  # Array of strings
    #   end
    class Base
      attr_reader :name,
                  :type,
                  :options,
                  :nesting_level

      # Creates a new attribute instance
      #
      # @param name [Symbol] The attribute name
      # @param type [Symbol] The attribute type (:string, :integer, :object, :array, etc.)
      # @param helpers [Array<Symbol>] Helper symbols (:required, :optional)
      # @param nesting_level [Integer] Current nesting depth (default: 0)
      # @param options [Hash] Attribute options (required, default, as, etc.)
      # @param block [Proc] Block for defining nested attributes (for object/array types)
      def initialize(name, type, *helpers, nesting_level: 0, **options, &block)
        @name = name
        @type = type
        @nesting_level = nesting_level

        validate_nesting_level!

        # Separate helpers from non-helper symbols.
        @helpers = extract_helpers(helpers)

        # Merge helper options with explicit options.
        merged_options = merge_options(@helpers, options)

        # Normalize all options to advanced mode.
        @options = OptionNormalizer.normalize(merged_options)

        apply_defaults!

        # Process nested attributes for object and array types.
        process_nested_attributes(&block) if block_given?
      end

      # Returns collection of nested attributes for this attribute
      #
      # @return [Collection] Collection of nested attributes
      def collection_of_attributes
        @collection_of_attributes ||= Collection.new
      end

      # Checks if this attribute has nested attributes
      #
      # @return [Boolean] True if attribute is object/array with nested attributes
      def nested?
        object_or_array? && collection_of_attributes.exists?
      end

      # Checks if this attribute is an object or array type
      #
      # @return [Boolean] True if type is :object or :array
      def object_or_array?
        object? || array?
      end

      # Checks if this attribute is an object type
      #
      # @return [Boolean] True if type is :object
      def object?
        @type == :object
      end

      # Checks if this attribute is an array type
      #
      # @return [Boolean] True if type is :array
      def array?
        @type == :array
      end

      private

      # Validates that nesting level doesn't exceed maximum allowed depth
      #
      # @raise [Treaty::Exceptions::NestedAttributes] If nesting exceeds limit
      # @return [void]
      def validate_nesting_level!
        return unless @nesting_level > Treaty::Engine.config.treaty.attribute_nesting_level

        raise Treaty::Exceptions::NestedAttributes,
              I18n.t("treaty.attributes.errors.nesting_level_exceeded",
                     level: @nesting_level,
                     max_level: Treaty::Engine.config.treaty.attribute_nesting_level)
      end

      # Extracts helper symbols from arguments
      #
      # @param helpers [Array] Mixed array that may contain helper symbols
      # @return [Array<Symbol>] Filtered array of valid helper symbols
      def extract_helpers(helpers)
        helpers.select do |helper|
          helper.is_a?(Symbol) && HelperMapper.helper?(helper)
        end
      end

      # Merges helper-derived options with explicit options
      #
      # @param helpers [Array<Symbol>] Helper symbols to convert
      # @param explicit_options [Hash] Explicitly provided options
      # @return [Hash] Merged options hash
      def merge_options(helpers, explicit_options)
        helper_options = HelperMapper.map(helpers)
        helper_options.merge(explicit_options)
      end

      # Applies default values for options based on context (request/response)
      # Must be implemented in subclasses
      #
      # @raise [Treaty::Exceptions::NotImplemented] If subclass doesn't implement
      # @return [void]
      def apply_defaults!
        # Must be implemented in subclasses
        raise Treaty::Exceptions::NotImplemented,
              I18n.t("treaty.attributes.errors.apply_defaults_not_implemented", class: self.class)
      end

      # Processes nested attributes block for object/array types
      # Must be implemented in subclasses
      #
      # @param block [Proc] Block containing nested attribute definitions
      # @raise [Treaty::Exceptions::NotImplemented] If subclass doesn't implement
      # @return [void]
      def process_nested_attributes
        # Must be implemented in subclasses
        raise Treaty::Exceptions::NotImplemented,
              I18n.t("treaty.attributes.errors.process_nested_not_implemented", class: self.class)
      end
    end
  end
end
