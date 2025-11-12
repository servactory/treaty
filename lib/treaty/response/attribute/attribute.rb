# frozen_string_literal: true

module Treaty
  module Response
    module Attribute
      # Response-specific attribute that defaults to required: false
      class Attribute < Treaty::Attribute::Base
        private

        def apply_defaults!
          # For response: optional by default (false).
          # message: nil means use I18n default message from validators
          @options[:required] ||= { is: false, message: nil }
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
