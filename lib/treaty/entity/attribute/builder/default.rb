# frozen_string_literal: true

module Treaty
  class Entity
    module Attribute
      module Builder
        # Default builder implementation for Entity context.
        # Creates Attribute instances with required: true by default.
        class Default < Base
          private

          def create_attribute(name, type, *helpers, nesting_level:, **options, &block)
            Attribute.new(name, type, *helpers, nesting_level:, **options, &block)
          end
        end
      end
    end
  end
end
