# frozen_string_literal: true

module Treaty
  module Request
    # Entity class for request definitions.
    # Attributes are required by default.
    #
    # This class is used internally when defining request blocks.
    # When you write a request block, Treaty creates an anonymous
    # class based on Request::Entity.
    class Entity
      include Treaty::Attribute::DSL

      class << self
        private

        # Creates a Request::Attribute::Attribute for this Request::Entity class
        #
        # @return [Request::Attribute::Attribute] Created attribute instance
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
