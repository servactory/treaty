# frozen_string_literal: true

module Treaty
  module Attribute
    module Validation
      # Validates a single attribute's options and values
      class AttributeValidator
        KNOWN_OPTIONS = %i[type required as default inclusion].freeze
        VALIDATING_OPTIONS = %i[type required].freeze
        MODIFYING_OPTIONS = %i[as default].freeze

        attr_reader :attribute

        def initialize(attribute)
          @attribute = attribute
        end

        # Validates that all options are known
        def validate_options!
          unknown_options = attribute.options.keys - KNOWN_OPTIONS

          return if unknown_options.empty?

          # TODO: It is necessary to implement a translation system (I18n).
          raise Treaty::Exceptions::Validation,
                "Unknown options for attribute '#{attribute.name}': #{unknown_options.join(', ')}. " \
                "Known options: #{KNOWN_OPTIONS.join(', ')}"
        end

        # Validates attribute schema (type, option structure)
        def validate_schema!
          validate_options!

          # Validate type
          type_validator.validate_schema!

          # Validate required option structure
          required_validator.validate_schema! if attribute.options.key?(:required)

          # Validate as option structure
          as_modifier.validate_schema! if attribute.options.key?(:as)
        end

        # Validates attribute value against its options
        def validate_value!(value)
          # First validate required, as it affects whether we check other validations
          required_validator.validate_value!(value) if attribute.options.key?(:required)

          # Only validate type if value is present (required already checked for presence)
          type_validator.validate_value!(value) unless value.nil?

          # Validate nested attributes for object/array types
          validate_nested!(value) if attribute.nested? && !value.nil?
        end

        private

        def type_validator
          @type_validator ||= Option::Validators::TypeValidator.new(
            attribute_name: attribute.name,
            attribute_type: attribute.type,
            option_config: nil
          )
        end

        def required_validator
          @required_validator ||= Option::Validators::RequiredValidator.new(
            attribute_name: attribute.name,
            attribute_type: attribute.type,
            option_config: attribute.options[:required]
          )
        end

        def as_modifier
          @as_modifier ||= Option::Modifiers::AsModifier.new(
            attribute_name: attribute.name,
            attribute_type: attribute.type,
            option_config: attribute.options[:as]
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

          # Validate each nested attribute
          attribute.collection_of_attributes.each do |nested_attr|
            nested_validator = AttributeValidator.new(nested_attr)
            nested_validator.validate_schema!

            nested_value = hash[nested_attr.name]
            nested_validator.validate_value!(nested_value)
          end
        end

        def validate_nested_array!(array) # rubocop:disable Metrics/MethodLength
          return unless array.is_a?(Array)

          # Validate each array element against nested attribute schema
          array.each_with_index do |element, index|
            attribute.collection_of_attributes.each do |nested_attr|
              nested_validator = AttributeValidator.new(nested_attr)
              nested_validator.validate_schema!

              nested_value = element.is_a?(Hash) ? element[nested_attr.name] : nil
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
