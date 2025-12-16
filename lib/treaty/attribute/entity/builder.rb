# frozen_string_literal: true

module Treaty
  module Attribute
    module Entity
      # Entity-specific attribute builder
      class Builder < Treaty::Attribute::Builder::Base
        protected

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

        # Creates an Entity attribute from another Entity attribute
        #
        # @param entity_attr [Treaty::Attribute::Entity::Attribute] Source attribute
        # @return [void]
        def create_attribute_from_entity(entity_attr)
          new_attr = Attribute.new(
            entity_attr.name,
            entity_attr.type,
            nesting_level: @nesting_level + 1,
            **entity_attr.options
          )

          copy_nested_attributes(entity_attr, new_attr) if entity_attr.nested?

          @collection_of_attributes << new_attr
        end

        # Recursively copies nested attributes from source to target
        #
        # @param source_attr [Treaty::Attribute::Base] Source attribute with nested attributes
        # @param target_attr [Treaty::Attribute::Base] Target attribute to copy into
        # @return [void]
        def copy_nested_attributes(source_attr, target_attr)
          nested_builder = self.class.new(target_attr.collection_of_attributes, @nesting_level + 1)

          source_attr.collection_of_attributes.each do |nested_attr|
            nested_builder.create_attribute_from_entity(nested_attr)
          end
        end
      end
    end
  end
end
