# frozen_string_literal: true

module Treaty
  class Entity
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
        # 5. **Entity Reuse** - Supports use_entity for copying attributes from Entity classes
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
        # ## Entity Reuse
        #
        # You can use `use_entity` to copy attributes from an Entity class:
        #
        # ```ruby
        # object :author do
        #   use_entity(AuthorDto)
        # end
        # ```
        #
        # Note: `use_entity` must be the only statement in the block.
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
        # - `deep_copy_attribute` - Deep copies an attribute with adjusted nesting level
        #
        # ## Architecture
        #
        # Used by:
        # - Request::Builder - For request attribute definitions
        # - Response::Builder - For response attribute definitions
        # - Entity::Builder - For entity attribute definitions
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
            @attributes_defined = false
          end

          # Uses an Entity class to copy its attributes into this builder's collection.
          # Must be the ONLY statement in the block - no other attributes allowed.
          #
          # @param entity_class [Class] Entity class (must be Treaty::Entity subclass)
          # @raise [Treaty::Exceptions::Validation] if entity_class is invalid
          # @raise [Treaty::Exceptions::Validation] if mixed with other attributes
          # @return [void]
          #
          # @example Using an Entity in a nested object
          #   object :author do
          #     use_entity(AuthorDto)
          #   end
          #
          # @example Using an Entity in a nested array
          #   array :items, :optional do
          #     use_entity(ItemDto)
          #   end
          def use_entity(entity_class)
            validate_use_entity_preconditions!
            validate_entity_class!(entity_class)

            @use_entity_called = true

            copy_attributes_from_entity(entity_class)
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
            validate_no_use_entity_called!

            @attributes_defined = true

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

          private

          # Creates an attribute instance (must be implemented in subclasses)
          #
          # @raise [Treaty::Exceptions::NotImplemented] If subclass doesn't implement
          # @return [Attribute::Base] Created attribute instance
          def create_attribute(*)
            raise Treaty::Exceptions::NotImplemented,
                  I18n.t("treaty.attributes.builder.not_implemented", class: self.class)
          end

          # Validates that use_entity can be called (no attributes defined before)
          #
          # @raise [Treaty::Exceptions::Validation] if attributes were defined before use_entity
          def validate_use_entity_preconditions!
            return unless @attributes_defined

            raise Treaty::Exceptions::Validation,
                  I18n.t("treaty.attributes.builder.use_entity_after_attributes")
          end

          # Validates that no use_entity was called before defining attributes
          #
          # @raise [Treaty::Exceptions::Validation] if use_entity was already called
          def validate_no_use_entity_called!
            return unless @use_entity_called

            raise Treaty::Exceptions::Validation,
                  I18n.t("treaty.attributes.builder.attributes_after_use_entity")
          end

          # Validates that entity_class is a valid Treaty::Entity subclass
          #
          # @param entity_class [Class] Entity class to validate
          # @raise [Treaty::Exceptions::Validation] if entity_class is not valid
          def validate_entity_class!(entity_class)
            return if entity_class.is_a?(Class) && entity_class < Treaty::Entity

            raise Treaty::Exceptions::Validation,
                  I18n.t(
                    "treaty.attributes.builder.invalid_entity_class",
                    type: entity_class.class,
                    value: entity_class
                  )
          end

          # Copies all attributes from entity_class to this builder's collection
          # with adjusted nesting levels.
          #
          # @param entity_class [Class] Source entity class
          def copy_attributes_from_entity(entity_class)
            entity_class.collection_of_attributes.each do |source_attribute|
              copied_attribute = deep_copy_attribute(source_attribute, @nesting_level)
              @collection_of_attributes << copied_attribute
            end
          end

          # Deep copies an attribute with adjusted nesting level.
          # Must be implemented by subclasses to use proper attribute types.
          #
          # @param source_attribute [Attribute::Base] Attribute to copy
          # @param new_nesting_level [Integer] New nesting level for copied attribute
          # @return [Attribute::Base] Copied attribute with correct type
          def deep_copy_attribute(_source_attribute, _new_nesting_level)
            raise Treaty::Exceptions::NotImplemented,
                  I18n.t(
                    "treaty.attributes.builder.deep_copy_not_implemented",
                    class: self.class
                  )
          end

          # Deep copies options hash, preserving Proc references
          # and recursively handling nested Hash/Array structures.
          #
          # @param options [Hash] Options to copy
          # @return [Hash] Copied options
          def deep_copy_options(options)
            options.transform_values { |value| deep_copy_value(value) }
          end

          # Deep copies a single value, handling nested structures.
          # Immutable types (Proc, Symbol, Numeric, nil, true, false) are returned as-is.
          # Hash and Array are recursively copied. Strings are duplicated if not frozen.
          #
          # @param value [Object] Value to copy
          # @return [Object] Copied value
          def deep_copy_value(value)
            case value
            when Hash  then value.transform_values { |v| deep_copy_value(v) }
            when Array then value.map { |v| deep_copy_value(v) }
            when String then value.frozen? ? value : value.dup
            else value
            end
          end
        end
      end
    end
  end
end
