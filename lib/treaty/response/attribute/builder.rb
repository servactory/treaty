# frozen_string_literal: true

module Treaty
  module Response
    module Attribute
      # Response-specific attribute builder
      class Builder < Treaty::Attribute::Builder::Base
        private

        def create_attribute(name, type, *helpers, nesting_level:, **options, &block)
          Attribute.new(
            name,
            type,
            *helpers,
            nesting_level:,
            **options,
            &block
          )
        end

        # Deep copies an attribute with adjusted nesting level for Response context.
        #
        # @param source_attribute [Treaty::Attribute::Base] Attribute to copy
        # @param new_nesting_level [Integer] New nesting level
        # @return [Response::Attribute::Attribute] Copied attribute
        def deep_copy_attribute(source_attribute, new_nesting_level) # rubocop:disable Metrics/MethodLength
          copied = Attribute.new(
            source_attribute.name,
            source_attribute.type,
            nesting_level: new_nesting_level,
            **deep_copy_options(source_attribute.options)
          )

          return copied unless source_attribute.nested?

          source_attribute.collection_of_attributes.each do |nested_source|
            nested_copied = deep_copy_attribute(nested_source, new_nesting_level + 1)
            copied.collection_of_attributes << nested_copied
          end

          copied
        end
      end
    end
  end
end
