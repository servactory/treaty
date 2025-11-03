# frozen_string_literal: true

module Treaty
  module Attribute
    module Validation
      class AttributeValidator
        KNOWN_OPTIONS = %i[type required as default inclusion].freeze
        VALIDATING_OPTIONS = %i[type required].freeze
        MODIFYING_OPTIONS = %i[as default].freeze

        attr_reader :attribute

        def initialize(attribute)
          @attribute = attribute
        end

        def validate_options!
          unknown_options = attribute.options.keys - KNOWN_OPTIONS

          return if unknown_options.empty?

          # TODO: It is necessary to implement a translation system (I18n).
          raise Treaty::Exceptions::Validation,
                "Unknown options for attribute '#{attribute.name}': #{unknown_options.join(', ')}. " \
                "Known options: #{KNOWN_OPTIONS.join(', ')}"
        end

        def validate_schema!
          validate_options!

          type_validator.validate_schema!
          required_validator.validate_schema! if attribute.options.key?(:required)
          as_modifier.validate_schema! if attribute.options.key?(:as)
        end

        def validate_value!(value)
          required_validator.validate_value!(value) if attribute.options.key?(:required)
          type_validator.validate_value!(value) unless value.nil?
          validate_nested!(value) if attribute.nested? && !value.nil?
        end

        private

        def type_validator
          @type_validator ||= Option::Validators::TypeValidator.new(
            attribute_name: attribute.name,
            attribute_type: attribute.type,
            option_schema: nil
          )
        end

        def required_validator
          @required_validator ||= Option::Validators::RequiredValidator.new(
            attribute_name: attribute.name,
            attribute_type: attribute.type,
            option_schema: attribute.options.fetch(:required)
          )
        end

        def as_modifier
          @as_modifier ||= Option::Modifiers::AsModifier.new(
            attribute_name: attribute.name,
            attribute_type: attribute.type,
            option_schema: attribute.options.fetch(:as)
          )
        end

        def validate_nested!(value)
          case attribute.type
          when :object
            validate_nested_object!(value)
          when :array
            validate_nested_array!(value)
          end
        end

        def validate_nested_object!(hash)
          return unless hash.is_a?(Hash)

          attribute.collection_of_attributes.each do |nested_attr|
            nested_validator = AttributeValidator.new(nested_attr)
            nested_validator.validate_schema!

            nested_value = hash.fetch(nested_attr.name)
            nested_validator.validate_value!(nested_value)
          end
        end

        def validate_nested_array!(array) # rubocop:disable Metrics/MethodLength
          return unless array.is_a?(Array)

          array.each_with_index do |element, index|
            attribute.collection_of_attributes.each do |nested_attr|
              nested_validator = AttributeValidator.new(nested_attr)
              nested_validator.validate_schema!

              nested_value = element.is_a?(Hash) ? element.fetch(nested_attr.name) : nil
              nested_validator.validate_value!(nested_value)
            rescue Treaty::Exceptions::Validation => e
              # TODO: It is necessary to implement a translation system (I18n).
              raise Treaty::Exceptions::Validation,
                    "Error in array '#{attribute.name}' at index #{index}: #{e.message}"
            end
          end
        end
      end
    end
  end
end
