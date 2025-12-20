# frozen_string_literal: true

module Treaty
  module Info
    module Entity
      class Builder
        attr_reader :attributes

        def self.build(...)
          new.build(...)
        end

        def build(collection_of_attributes:, entity_class: nil, preset: nil)
          @preset = build_preset(entity_class, preset)

          build_all(
            attributes: collection_of_attributes
          )

          self
        end

        private

        def build_all(attributes:)
          @attributes = build_attributes_hash(attributes)
        end

        # Creates Preset instance from options hash
        #
        # @param entity_class [Class] Entity class
        # @param preset_options [Hash, nil] Preset options
        # @return [Treaty::Entity::Context::Preset, nil] Preset instance or nil
        def build_preset(entity_class, preset_options)
          return nil if preset_options.nil? || preset_options.empty?
          return nil if entity_class.nil?

          Treaty::Entity::Context::Preset.new(entity_class, **preset_options)
        end

        ##########################################################################

        def build_attributes_hash(collection, current_level = 0)
          collection.to_h do |attribute|
            [
              attribute.name,
              {
                type: attribute.type,
                options: compute_effective_options(attribute),
                attributes: build_nested_attributes(attribute, current_level)
              }
            ]
          end
        end

        def build_nested_attributes(attribute, current_level)
          return {} unless attribute.nested?

          build_attributes_hash(attribute.collection_of_attributes, current_level + 1)
        end

        # Computes effective options by applying preset to non-explicit options
        #
        # @param attribute [Treaty::Entity::Attribute::Base] Attribute to compute options for
        # @return [Hash] Effective options
        def compute_effective_options(attribute)
          return attribute.options if @preset.nil?

          # Deep copy to avoid mutating original attribute options
          options_copy = deep_dup(attribute.options)
          @preset.merge_with(options_copy, attribute.explicit_options)
        end

        # Deep duplicates a hash
        #
        # @param hash [Hash] Hash to duplicate
        # @return [Hash] Deep copy of the hash
        def deep_dup(hash)
          hash.transform_values do |value|
            value.is_a?(Hash) ? deep_dup(value) : value
          end
        end
      end
    end
  end
end
