# frozen_string_literal: true

module Treaty
  module Response
    module Attribute
      class Builder < Treaty::Attribute::Builder::Base
        private

        def create_attribute(name, type, *helpers, nesting_level:, **options, &block)
          Attribute.new(
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
