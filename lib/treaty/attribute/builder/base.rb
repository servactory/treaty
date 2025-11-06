# frozen_string_literal: true

module Treaty
  module Attribute
    module Builder
      # Base DSL builder for defining attributes in request/response scopes.
      #
      # ## Purpose
      #
      # Provides the DSL interface for defining attributes within scopes.
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
      #   scope :user do
      #     string :name, :required
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
        # @raise [NotImplementedError] If subclass doesn't implement
        # @return [Attribute::Base] Created attribute instance
        def create_attribute(*)
          # Must be implemented in subclasses
          raise NotImplementedError,
                I18n.t("treaty.builder.not_implemented", class: self.class)
        end
      end
    end
  end
end
