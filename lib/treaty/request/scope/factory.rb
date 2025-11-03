# frozen_string_literal: true

module Treaty
  module Request
    module Scope
      class Factory
        attr_reader :name

        def initialize(name)
          @name = name
        end

        def attribute(name, type, *helpers, **options, &block)
          collection_of_attributes << Attribute::Attribute.new(
            name,
            type,
            *helpers,
            nesting_level: 0,
            **options,
            &block
          )
        end

        def collection_of_attributes
          @collection_of_attributes ||= Attribute::Collection.new
        end

        ########################################################################

        def method_missing(type, *helpers, **options, &block)
          name = helpers.shift

          attribute(name, type, *helpers, **options, &block)
        end

        def respond_to_missing?(name, *)
          super
        end
      end
    end
  end
end
