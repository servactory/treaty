# frozen_string_literal: true

module Treaty
  module Exceptions
    # Raised when Entity class is used incorrectly in attribute definitions
    #
    # ## Purpose
    #
    # Ensures proper usage of Entity classes with the `use_entity` method:
    # - Entity class must be a Treaty::Entity subclass
    # - Cannot mix `use_entity` with additional attributes in the same block
    # - `use_entity` must be called before any other attributes
    #
    # ## Usage
    #
    # Raised when `use_entity` is used incorrectly:
    #
    # ```ruby
    # # CORRECT - use_entity is the only content in the block
    # object :author do
    #   use_entity(Posts::AuthorDto)
    # end
    #
    # # WRONG - mixing use_entity with additional attributes
    # object :author do
    #   use_entity(Posts::AuthorDto)
    #   string :extra_field  # Raises EntityUsage exception
    # end
    #
    # # WRONG - use_entity called after attributes
    # object :author do
    #   string :name
    #   use_entity(Posts::AuthorDto)  # Raises EntityUsage exception
    # end
    #
    # # WRONG - non-Entity class passed
    # object :author do
    #   use_entity(String)  # Raises EntityUsage exception
    # end
    # ```
    #
    # ## Integration
    #
    # Can be rescued by application controllers:
    #
    # ```ruby
    # rescue_from Treaty::Exceptions::EntityUsage, with: :render_entity_error
    #
    # def render_entity_error(exception)
    #   render json: { error: exception.message }, status: :unprocessable_entity
    # end
    # ```
    #
    # ## Best Practices
    #
    # - Use `use_entity` as the only statement in object/array blocks
    # - Define reusable Entity classes for complex nested structures
    # - Keep Entity definitions in separate files for maintainability
    class EntityUsage < Base
    end
  end
end
