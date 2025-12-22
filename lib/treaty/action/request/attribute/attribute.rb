# frozen_string_literal: true

module Treaty
  module Action
    module Request
      module Attribute
        class Attribute < Treaty::Entity::Attribute::Base
          private

          def apply_defaults!
            @options[:required] ||= { is: true, message: nil }
          end

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
