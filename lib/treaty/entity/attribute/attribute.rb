# frozen_string_literal: true

require_relative "builder/base"

module Treaty
  class Entity
    module Attribute
      # Unified attribute class for Entity context.
      # Default: required: true
      # Override via preset for Response context.
      class Attribute < Base
        private

        def apply_defaults!
          # Use default_required from context (true for Entity, false for Request/Response)
          # message: nil means use I18n default message from validators
          @options[:required] ||= { is: @default_required, message: nil }
        end

        def process_nested_attributes(&block)
          return unless object_or_array?

          # Pass default_required to nested builder so nested attributes inherit the same default
          builder = Builder::Default.new(collection_of_attributes, @nesting_level + 1,
                                         default_required: @default_required)
          builder.instance_eval(&block)
        end
      end
    end
  end
end
