# frozen_string_literal: true

module Treaty
  module Response
    # Entity class for response definitions.
    # Attributes are optional by default.
    #
    # This class is used internally when defining response blocks.
    # When you write a response block, Treaty creates an anonymous
    # class based on Response::Entity.
    class Entity
      include Treaty::Attribute::DSL

      class << self
        private

        # Creates a Response::Attribute::Attribute for this Response::Entity class
        #
        # @return [Response::Attribute::Attribute] Created attribute instance
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
