# frozen_string_literal: true

module Treaty
  module Attribute
    class Base
      attr_reader :name,
                  :type,
                  :options,
                  :nesting_level

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

      def collection_of_attributes
        @collection_of_attributes ||= Collection.new
      end

      def nested?
        object_or_array? && collection_of_attributes.exists?
      end

      def object_or_array?
        object? || array?
      end

      def object?
        @type == :object
      end

      def array?
        @type == :array
      end

      private

      def validate_nesting_level!
        return unless @nesting_level > Treaty::Engine.config.treaty.attribute_nesting_level

        # TODO: It is necessary to implement a translation system (I18n).
        raise Treaty::Exceptions::NestedAttributes,
              "Nesting level #{@nesting_level} exceeds maximum allowed level of " \
              "#{Treaty::Engine.config.treaty.attribute_nesting_level}"
      end

      def extract_helpers(helpers)
        helpers.select do |helper|
          helper.is_a?(Symbol) && HelperMapper.helper?(helper)
        end
      end

      def merge_options(helpers, explicit_options)
        helper_options = HelperMapper.map(helpers)
        helper_options.merge(explicit_options)
      end

      def apply_defaults!
        # Must be implemented in subclasses
        raise NotImplementedError, "#{self.class} must implement #apply_defaults!"
      end

      def process_nested_attributes(&block)
        # Must be implemented in subclasses
        raise NotImplementedError, "#{self.class} must implement #process_nested_attributes"
      end
    end
  end
end
