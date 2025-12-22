# frozen_string_literal: true

module Treaty
  module Entity
    # Base class for defining reusable entity classes in Treaty.
    #
    # ## Purpose
    #
    # Treaty::Entity::Base provides a base class for creating reusable entity classes
    # that can be used in both request and response definitions. This allows
    # for better code organization and reusability of common data structures.
    #
    # ## Usage
    #
    # Create an entity class by inheriting from Treaty::Entity::Base:
    #
    # ```ruby
    # module Posts
    #   module Create
    #     class ResponseEntity < Treaty::Entity::Base
    #       string :id
    #       string :title
    #       string :content
    #       datetime :created_at
    #     end
    #   end
    # end
    # ```
    #
    # Then use it in your treaty definitions:
    #
    # ```ruby
    # class Posts::CreateTreaty < ApplicationTreaty
    #   version 1 do
    #     request Posts::Create::RequestEntity
    #     response 201, Posts::Create::ResponseEntity
    #   end
    # end
    # ```
    #
    # ## Attribute Defaults
    #
    # Unlike request/response blocks, Entity attributes are required by default:
    # - All attributes have `required: true` unless explicitly marked as `:optional`
    # - Use `:optional` helper to make attributes optional:
    #   ```ruby
    #   string :title           # required by default
    #   string :summary, :optional  # optional
    #   ```
    #
    # ## Features
    #
    # - **Type Safety** - Enforce strict type checking for all attributes
    # - **Nested Structures** - Support for nested objects and arrays
    # - **Validation** - Built-in validation for all attribute types
    # - **Reusability** - Define once, use in multiple treaties
    # - **Options** - Full support for attribute options (required, default, as, etc.)
    #
    # ## Supported Types
    #
    # - `string` - String values
    # - `integer` - Integer values
    # - `boolean` - Boolean values (true/false)
    # - `datetime` - DateTime values
    # - `array` - Array values (with nested type definition)
    # - `object` - Object values (with nested attributes)
    class Base
      include Info::DSL
      include Attribute::DSL

      class << self
        private

        # Creates an Entity::Attribute for this Entity class
        #
        # @return [Entity::Attribute::Attribute] Created attribute instance
        def create_attribute(name, type, *helpers, nesting_level:, **options, &block)
          Attribute::Attribute.new(
            name,
            type,
            *helpers,
            nesting_level:,
            **options,
            &block
          )
        end
      end
    end
  end
end
