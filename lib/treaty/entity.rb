# frozen_string_literal: true

module Treaty
  # Base class for defining DTO (Data Transfer Object) entities in Treaty.
  #
  # ## Purpose
  #
  # Treaty::Entity provides a base class for creating reusable DTO classes
  # that can be used in both request and response definitions. This allows
  # for better code organization and reusability of common data structures.
  #
  # ## Usage
  #
  # Create a DTO class by inheriting from Treaty::Entity:
  #
  # ```ruby
  # class PostEntity < Treaty::Entity
  #   string :id
  #   string :title
  #   string :content
  #   datetime :created_at
  # end
  # ```
  #
  # Then use it in your treaty definitions:
  #
  # ```ruby
  # class CreateTreaty < ApplicationTreaty
  #   version 1 do
  #     request PostEntity
  #     response 201, PostEntity
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
  class Entity
    include Info::Entity::DSL
    include Attribute::DSL

    class << self
      private

      # Creates an Attribute::Entity::Attribute for this Entity class
      #
      # @return [Attribute::Entity::Attribute] Created attribute instance
      def create_attribute(name, type, *helpers, nesting_level:, **options, &block)
        Attribute::Entity::Attribute.new(
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
