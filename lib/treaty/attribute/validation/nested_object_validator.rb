# frozen_string_literal: true

module Treaty
  module Attribute
    module Validation
      class NestedObjectValidator
        attr_reader :attribute

        def initialize(attribute)
          @attribute = attribute
          @validators_cache = nil
        end

        def validate!(hash)
          return unless hash.is_a?(Hash)

          validators.each do |nested_attribute, nested_validator|
            nested_value = hash.fetch(nested_attribute.name, nil)
            nested_validator.validate_value!(nested_value)
          end
        end

        private

        def validators
          @validators ||= build_validators
        end

        def build_validators
          attribute.collection_of_attributes.each_with_object({}) do |nested_attribute, cache|
            validator = AttributeValidator.new(nested_attribute)
            validator.validate_schema!
            cache[nested_attribute] = validator
          end
        end
      end
    end
  end
end
