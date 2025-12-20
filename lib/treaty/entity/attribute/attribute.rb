# frozen_string_literal: true

require_relative "builder/base"
require_relative "builder/default"

module Treaty
  class Entity
    module Attribute
      # Unified attribute class for Entity context.
      # Default: required: true
      # Override via preset for Response context.
      class Attribute < Base
        private

        def apply_defaults!
          # Entity attributes are required by default.
          # Use .preset(required: false) at validation time for optional behavior.
          @options[:required] ||= { is: true, message: nil }
        end

        def process_nested_attributes(&block)
          return unless object_or_array?

          builder = Builder::Default.new(collection_of_attributes, @nesting_level + 1)
          builder.instance_eval(&block)
        end
      end
    end
  end
end
