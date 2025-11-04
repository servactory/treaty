# frozen_string_literal: true

module Treaty
  module Attribute
    module Validation
      class NestedArrayValidator
        attr_reader :attribute

        def initialize(attribute)
          @attribute = attribute
          @self_validators = nil
          @regular_validators = nil
        end

        def validate!(array)
          return unless array.is_a?(Array)

          array.each_with_index do |element, index|
            validate_self_element!(element, index) if self_validators.any?

            validate_regular_element!(element, index) if regular_validators.any?
          end
        end

        private

        def validate_self_element!(element, index) # rubocop:disable Metrics/MethodLength
          errors = []

          validated = self_validators.any? do |validator|
            validator.validate_value!(element)
            true
          rescue Treaty::Exceptions::Validation => e
            errors << e.message
            false
          end

          return if validated

          # TODO: It is necessary to implement a translation system (I18n).
          raise Treaty::Exceptions::Validation,
                "Error in array '#{attribute.name}' at index #{index}: " \
                "Element must match one of the defined types. Errors: #{errors.join('; ')}"
        end

        def validate_regular_element!(element, index) # rubocop:disable Metrics/MethodLength
          unless element.is_a?(Hash)
            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Error in array '#{attribute.name}' at index #{index}: Expected Hash but got #{element.class}"
          end

          regular_validators.each do |nested_attribute, validator|
            nested_value = element.fetch(nested_attribute.name, nil)
            validator.validate_value!(nested_value)
          rescue Treaty::Exceptions::Validation => e
            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Error in array '#{attribute.name}' at index #{index}: #{e.message}"
          end
        end

        ########################################################################

        def self_validators
          @self_validators ||= build_self_validators
        end

        def regular_validators
          @regular_validators ||= build_regular_validators
        end

        ########################################################################

        def build_self_validators
          attribute.collection_of_attributes
                   .select { |attr| attr.name == :_self }
                   .map do |self_attribute|
            validator = AttributeValidator.new(self_attribute)
            validator.validate_schema!
            validator
          end
        end

        def build_regular_validators
          attribute.collection_of_attributes
                   .reject { |attr| attr.name == :_self }
                   .each_with_object({}) do |nested_attribute, cache|
            validator = AttributeValidator.new(nested_attribute)
            validator.validate_schema!
            cache[nested_attribute] = validator
          end
        end
      end
    end
  end
end
