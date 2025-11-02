# frozen_string_literal: true

module Treaty
  module Attribute
    class Attribute
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

      # TODO: Currently not in use.
      def validate!(_value) # rubocop:disable Naming/PredicateMethod
        # TODO: Implement validation logic
        # This method will be implemented in future iterations.
        # It should check:
        # - Type validation
        # - Required/optional validation
        # - Custom option validations (in, as, etc.)
        # - Nested attribute validations
        true
      end

      def collection_of_attributes
        @collection_of_attributes ||= Collection.new
      end

      # TODO: Currently not in use.
      # def required?
      #   @options.dig(:required, :is) == true
      # end

      # TODO: Currently not in use.
      # def optional?
      #   !required?
      # end

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

      # Validates that nesting level doesn't exceed maximum.
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
        # TODO: It is necessary to implement a translation system (I18n).
        @options[:required] ||= { is: true, message: nil }
      end

      def process_nested_attributes(&block)
        return unless object_or_array?

        builder = Builder.new(collection_of_attributes, @nesting_level + 1)
        builder.instance_eval(&block)
      end
    end
  end
end
