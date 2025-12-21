# frozen_string_literal: true

module Treaty
  class Entity
    module Attribute
      module Builder
        # Default builder implementation for Entity context.
        # Creates Attribute instances with required: true by default.
        class Default < Base
          private

          def create_attribute(name, type, *helpers, nesting_level:, **options, &block)
            Attribute.new(name, type, *helpers, nesting_level:, **options, &block)
          end

          # Deep copies an attribute with adjusted nesting level for Entity context.
          #
          # Only copies options that were explicitly set by user.
          # Options from apply_defaults! should not be copied,
          # allowing target context to apply its own defaults via preset.
          #
          # @param source_attribute [Treaty::Entity::Attribute::Base] Attribute to copy
          # @param new_nesting_level [Integer] New nesting level
          # @return [Treaty::Entity::Attribute::Attribute] Copied attribute
          def deep_copy_attribute(source_attribute, new_nesting_level) # rubocop:disable Metrics/MethodLength
            explicit_only = source_attribute.options.select do |key, _|
              source_attribute.explicit?(key)
            end

            copied = Attribute.new(
              source_attribute.name,
              source_attribute.type,
              nesting_level: new_nesting_level,
              **deep_copy_options(explicit_only)
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
end
