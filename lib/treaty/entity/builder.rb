# frozen_string_literal: true

module Treaty
  module Entity
    # DSL builder for defining entity attributes.
    #
    # ## Purpose
    #
    # Provides Entity-specific implementation of the attribute builder.
    # Creates Entity::Attribute::Attribute instances with **required by default**
    # behavior (unlike Request/Response which have different defaults).
    #
    # ## Inheritance
    #
    # Extends Treaty::Entity::Attribute::Builder::Base which provides:
    # - DSL interface (string, integer, object, array, etc.)
    # - method_missing magic for type-based method calls
    # - Helper support (:required, :optional)
    # - Entity reuse via use_entity
    #
    # ## Usage
    #
    # Used internally by:
    # - Entity::Attribute::Attribute (when processing nested object/array blocks)
    #
    # ## Default Behavior
    #
    # Entity attributes default to **required: true**, meaning all fields
    # must be present unless explicitly marked `:optional`.
    #
    # ## DSL Example
    #
    #   class UserEntity < Treaty::Entity::Base
    #     object :user do
    #       string :id                    # required by default
    #       string :name                  # required by default
    #       string :bio, :optional        # explicitly optional
    #       object :profile do
    #         string :avatar_url
    #       end
    #     end
    #   end
    #
    # ## Methods
    #
    # Implements abstract methods from base class:
    # - `create_attribute` - Creates Entity::Attribute::Attribute
    # - `deep_copy_attribute` - Deep copies attribute for use_entity support
    class Builder < Treaty::Entity::Attribute::Builder::Base
      private

      # Creates a new entity attribute instance
      #
      # Called by base class when defining attributes via DSL.
      #
      # @param name [Symbol] Attribute name
      # @param type [Symbol] Attribute type (:string, :integer, :object, etc.)
      # @param helpers [Array<Symbol>] Helper symbols (:required, :optional)
      # @param nesting_level [Integer] Current nesting depth
      # @param options [Hash] Attribute options (default:, format:, etc.)
      # @param block [Proc] Block for nested attributes (object/array)
      # @return [Entity::Attribute::Attribute] Created attribute instance
      def create_attribute(name, type, *helpers, nesting_level:, **options, &block)
        Treaty::Entity::Attribute::Attribute.new(
          name,
          type,
          *helpers,
          nesting_level:,
          **options,
          &block
        )
      end

      # Deep copies an attribute with adjusted nesting level
      #
      # Used when copying attributes from other Entity classes via use_entity.
      # Recursively copies nested attributes for object/array types.
      #
      # @param source_attribute [Entity::Attribute::Base] Source attribute to copy
      # @param new_nesting_level [Integer] Nesting level for copied attribute
      # @return [Entity::Attribute::Attribute] Deep copied attribute
      def deep_copy_attribute(source_attribute, new_nesting_level) # rubocop:disable Metrics/MethodLength
        copied = Treaty::Entity::Attribute::Attribute.new(
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
