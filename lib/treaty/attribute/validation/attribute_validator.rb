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
          @nested_object_validator = nil
          @nested_array_validator = nil
          @type_validator = nil
          @required_validator = nil
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

        private

        # TODO: Need to apply DefaultModifier here.

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
            nested_object_validator.validate!(value)
          when :array
            nested_array_validator.validate!(value)
          end
        end

        def nested_object_validator
          @nested_object_validator ||= NestedObjectValidator.new(attribute)
        end

        def nested_array_validator
          @nested_array_validator ||= NestedArrayValidator.new(attribute)
        end
      end
    end
  end
end
