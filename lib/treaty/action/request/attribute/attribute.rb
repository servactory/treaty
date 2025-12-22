# frozen_string_literal: true

module Treaty
  module Action
    module Request
      module Attribute
        # Request-specific attribute definition.
        #
        # ## Purpose
        #
        # Extends Entity::Attribute::Base with Request-specific behavior.
        # Key difference: attributes are **required by default**.
        #
        # ## Default Behavior
        #
        # Unlike Response attributes (optional by default), Request attributes
        # default to `required: true`. This enforces strict input validation.
        #
        # ## Usage
        #
        # Created internally by:
        # - Request::Attribute::Builder (when defining nested attributes)
        # - Request::Entity (when defining top-level attributes)
        #
        # ## Nesting
        #
        # Object and array types create nested builders:
        #
        #   request do
        #     object :post do           # Creates Attribute with nested builder
        #       string :title           # Nested attribute (required by default)
        #       array :tags do          # Nested array
        #         string :_self         # Array element definition
        #       end
        #     end
        #   end
        #
        # ## Example
        #
        #   # These are equivalent:
        #   string :title               # required by default
        #   string :title, :required    # explicit required
        #
        #   # Must explicitly mark optional:
        #   string :bio, :optional
        class Attribute < Treaty::Entity::Attribute::Base
          private

          # Sets default required behavior for request attributes
          #
          # Request attributes are required by default (is: true).
          # This can be overridden with `:optional` helper or `required: false`.
          #
          # @return [void]
          def apply_defaults!
            @options[:required] ||= { is: true, message: nil }
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
