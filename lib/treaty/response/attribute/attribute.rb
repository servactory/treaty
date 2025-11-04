# frozen_string_literal: true

module Treaty
  module Response
    module Attribute
      class Attribute < Treaty::Attribute::Base
        private

        def apply_defaults!
          # For response: optional by default (false).
          # TODO: It is necessary to implement a translation system (I18n).
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
