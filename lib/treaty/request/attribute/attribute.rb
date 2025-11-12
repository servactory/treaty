# frozen_string_literal: true

module Treaty
  module Request
    module Attribute
      # Request-specific attribute that defaults to required: true
      class Attribute < Treaty::Attribute::Entity::Attribute
        private

        def apply_defaults!
          # For request: required by default (true).
          # message: nil means use I18n default message from validators
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
