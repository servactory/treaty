# frozen_string_literal: true

module Treaty
  module Attribute
    module Builder
      # Base DSL builder for defining attributes in request/response definitions.
      #
      # ## Purpose
      #
      # Provides the DSL interface for defining attributes within objects.
      # Handles method_missing magic to support type-based method calls.
      #
      # ## Responsibilities
      #
      # 1. **DSL Interface** - Provides clean syntax for attribute definitions
      # 2. **Method Dispatch** - Routes type methods (string, integer, etc.) to attribute creation
      # 3. **Helper Support** - Handles helper symbols in various positions
      # 4. **Nesting Tracking** - Tracks nesting level for nested attributes
      #
      # ## DSL Usage
      #
      # The builder enables this clean DSL syntax:
      #
      # ```ruby
      # request do
      #   object :user do
      #     string :name
      #     integer :age, default: 18
      #     object :profile do
      #       string :bio
      #     end
      #   end
      # end
      # ```
      #
      # ## Method Dispatch
      #
      # ### Type-based Methods
      # When you call `string :name`, it routes through `method_missing`:
      # 1. `string` becomes the type
      # 2. `:name` becomes the attribute name
      # 3. Calls `attribute(:name, :string, ...)`
      #
      # ### Helper Position Handling
      # Handles helpers in different positions:
      #
      # ```ruby
      # string :required, :name    # Helper first, then name
      # string :name, :required    # Name first, then helper
      # ```
      #
      # Both resolve to the same attribute definition.
      #
      # ## Nesting
      #
      # Tracks nesting level for:
      # - Validation (enforcing maximum nesting depth)
      # - Error messages (showing context)
      #
      # Maximum nesting level is configured in Treaty::Engine.config.
      #
      # ## Subclass Requirements
      #
      # Subclasses must implement:
      # - `create_attribute` - Creates the appropriate attribute type (Request/Response)
      #
      # ## Architecture
      #
      # Used by:
      # - Request::Builder - For request attribute definitions
      # - Response::Builder - For response attribute definitions
      class Base
        attr_reader :nesting_level,
                    :collection_of_attributes

        # Creates a new builder instance
        #
        # @param collection_of_attributes [Collection] Collection to add attributes to
        # @param nesting_level [Integer] Current nesting depth
        def initialize(collection_of_attributes, nesting_level)
          @collection_of_attributes = collection_of_attributes
          @nesting_level = nesting_level
          @use_entity_called = false
        end

        # References an Entity class to copy its attributes into the current block
        #
        # @param entity_class [Class] A Treaty::Entity subclass
        # @raise [Treaty::Exceptions::NestedAttributes] If entity_class is not a Treaty::Entity subclass
        # @raise [Treaty::Exceptions::NestedAttributes] If attributes were already defined in block
        # @return [void]
        #
        # @example Using in object block
        #   object :author do
        #     use_entity(Posts::AuthorDto)
        #   end
        #
        # @example Using in array block
        #   array :socials, :optional do
        #     use_entity(Posts::SocialDto)
        #   end
        def use_entity(entity_class)
          validate_entity_class!(entity_class)
          raise_if_attributes_exist!

          @use_entity_called = true
          copy_entity_attributes(entity_class)
        end

        # Defines an attribute with explicit type
        #
        # @param name [Symbol] The attribute name
        # @param type [Symbol] The attribute type
        # @param helpers [Array<Symbol>] Helper symbols (:required, :optional)
        # @param options [Hash] Attribute options
        # @param block [Proc] Block for nested attributes
        # @return [void]
        def attribute(name, type, *helpers, **options, &block)
          raise_if_use_entity_called!

          @collection_of_attributes << create_attribute(
            name,
            type,
            *helpers,
            nesting_level: @nesting_level,
            **options,
            &block
          )
        end

        # Handles DSL methods like `string :name` where method name is the type
        #
        # @param type [Symbol] The attribute type (method name)
        # @param name [Symbol] The attribute name (first argument)
        # @param helpers [Array<Symbol>] Helper symbols
        # @param options [Hash] Attribute options
        # @param block [Proc] Block for nested attributes
        # @return [void]
        def method_missing(type, name, *helpers, **options, &block)
          if name.is_a?(Symbol) && HelperMapper.helper?(name)
            helpers.unshift(name)
            name = helpers.shift
          end

          attribute(name, type, *helpers, **options, &block)
        end

        # Checks if method should be handled by method_missing
        #
        # @param name [Symbol] Method name
        # @return [Boolean]
        def respond_to_missing?(name, *)
          super
        end

        protected

        # Creates an attribute instance (must be implemented in subclasses)
        #
        # @raise [Treaty::Exceptions::NotImplemented] If subclass doesn't implement
        # @return [Attribute::Base] Created attribute instance
        def create_attribute(*)
          # Must be implemented in subclasses
          raise Treaty::Exceptions::NotImplemented,
                I18n.t("treaty.attributes.builder.not_implemented", class: self.class)
        end

        # Creates an attribute from an Entity attribute (must be implemented in subclasses)
        #
        # @param entity_attribute [Treaty::Attribute::Entity::Attribute] Source entity attribute
        # @raise [Treaty::Exceptions::NotImplemented] If subclass doesn't implement
        # @return [void]
        def create_attribute_from_entity(_entity_attribute)
          # Must be implemented in subclasses
          raise Treaty::Exceptions::NotImplemented,
                I18n.t("treaty.attributes.builder.create_attribute_not_implemented", class: self.class)
        end

        private

        # Validates that entity_class is a Treaty::Entity subclass
        #
        # @param entity_class [Class] Class to validate
        # @raise [Treaty::Exceptions::Validation] If not a Treaty::Entity subclass
        # @return [void]
        def validate_entity_class!(entity_class)
          return if entity_class?(entity_class)

          raise Treaty::Exceptions::NestedAttributes,
                I18n.t(
                  "treaty.attributes.builder.use_entity_invalid_class",
                  type: entity_class.class.name,
                  value: entity_class.inspect
                )
        end

        # Checks if a class is a Treaty::Entity subclass
        #
        # @param klass [Object] Object to check
        # @return [Boolean] True if klass is a Treaty::Entity subclass
        def entity_class?(klass)
          klass.is_a?(Class) && klass < Treaty::Entity
        end

        # Raises an error if use_entity was already called
        #
        # @raise [Treaty::Exceptions::Validation] If use_entity was called
        # @return [void]
        def raise_if_use_entity_called!
          return unless @use_entity_called

          raise Treaty::Exceptions::NestedAttributes,
                I18n.t("treaty.attributes.builder.use_entity_no_additional_attributes")
        end

        # Raises an error if attributes already exist in the collection
        #
        # @raise [Treaty::Exceptions::Validation] If attributes exist
        # @return [void]
        def raise_if_attributes_exist!
          return if @collection_of_attributes.empty?

          raise Treaty::Exceptions::NestedAttributes,
                I18n.t("treaty.attributes.builder.use_entity_must_be_first")
        end

        # Copies all attributes from an Entity class into the current collection
        #
        # Each copied attribute gets nesting_level + 1, which provides
        # protection against circular references through the existing
        # attribute_nesting_level configuration.
        #
        # @param entity_class [Class] A Treaty::Entity subclass
        # @return [void]
        def copy_entity_attributes(entity_class)
          entity_class.collection_of_attributes.each do |entity_attribute|
            create_attribute_from_entity(entity_attribute)
          end
        end
      end
    end
  end
end
