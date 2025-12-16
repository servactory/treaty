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
        # @param entity_attribute [Treaty::Attribute::Entity::Attribute] Source attribute
        # @return [void]
        def create_attribute_from_entity(entity_attribute)
          new_attribute = Attribute.new(
            entity_attribute.name,
            entity_attribute.type,
            nesting_level: @nesting_level + 1,
            **entity_attribute.options
          )

          copy_nested_attributes(entity_attribute, new_attribute) if entity_attribute.nested?

          @collection_of_attributes << new_attribute
        end

        # Recursively copies nested attributes from source to target
        #
        # @param source_attribute [Treaty::Attribute::Base] Source attribute with nested attributes
        # @param target_attribute [Treaty::Attribute::Base] Target attribute to copy into
        # @return [void]
        def copy_nested_attributes(source_attribute, target_attribute)
          nested_builder = self.class.new(target_attribute.collection_of_attributes, @nesting_level + 1)

          source_attribute.collection_of_attributes.each do |nested_attribute|
            nested_builder.create_attribute_from_entity(nested_attribute)
          end
        end
      end
    end
  end
end
