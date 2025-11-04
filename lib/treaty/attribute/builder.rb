# frozen_string_literal: true

module Treaty
  module Attribute
    class Builder
      attr_reader :nesting_level,
                  :collection_of_attributes,
                  :context

      def initialize(collection_of_attributes, nesting_level, context = :request)
        @collection_of_attributes = collection_of_attributes
        @nesting_level = nesting_level
        @context = context
      end

      def attribute(name, type, *helpers, **options, &block)
        @collection_of_attributes << Attribute.new(
          name,
          type,
          *helpers,
          nesting_level: @nesting_level,
          context: @context,
          **options,
          &block
        )
      end

      def method_missing(type, name, *helpers, **options, &block)
        if name.is_a?(Symbol) && HelperMapper.helper?(name)
          helpers.unshift(name)
          name = helpers.shift
        end

        attribute(name, type, *helpers, **options, &block)
      end

      def respond_to_missing?(name, *)
        super
      end
    end
  end
end
