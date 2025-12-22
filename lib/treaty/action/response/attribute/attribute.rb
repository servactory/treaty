# frozen_string_literal: true

module Treaty
  module Action
    module Response
      module Attribute
        # Response-specific attribute definition.
        #
        # ## Purpose
        #
        # Extends Entity::Attribute::Base with Response-specific behavior.
        # Key difference: attributes are **optional by default**.
        #
        # ## Default Behavior
        #
        # Unlike Request attributes (required by default), Response attributes
        # default to `required: false`. This allows flexible response structures
        # where not all fields must be present.
        #
        # ## Usage
        #
        # Created internally by:
        # - Response::Attribute::Builder (when defining nested attributes)
        # - Response::Entity (when defining top-level attributes)
        #
        # ## Nesting
        #
        # Object and array types create nested builders:
        #
        #   response 200 do
        #     object :post do           # Creates Attribute with nested builder
        #       string :title           # Nested attribute (optional by default)
        #       array :comments do      # Nested array
        #         object :_self do      # Array element definition
        #           string :text
        #         end
        #       end
        #     end
        #   end
        #
        # ## Example
        #
        #   # These are equivalent:
        #   string :title               # optional by default
        #   string :title, :optional    # explicit optional
        #
        #   # Must explicitly mark required:
        #   string :id, :required
        class Attribute < Treaty::Entity::Attribute::Base
          private

          # Sets default required behavior for response attributes
          #
          # Response attributes are optional by default (is: false).
          # This can be overridden with `:required` helper or `required: true`.
          #
          # @return [void]
          def apply_defaults!
            @options[:required] ||= { is: false, message: nil }
          end

          # Creates nested builder for object/array type processing
          #
          # When a block is given to object or array attributes,
          # creates a Builder to process the nested attribute definitions.
          #
          # @param block [Proc] Block containing nested attribute definitions
          # @return [void]
          def process_nested_attributes(&block)
            return unless object_or_array?

            builder = Builder.new(collection_of_attributes, @nesting_level + 1)
            builder.instance_eval(&block)
          end
        end
      end
    end
  end
end
