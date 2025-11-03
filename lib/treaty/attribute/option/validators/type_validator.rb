# frozen_string_literal: true

module Treaty
  module Attribute
    module Option
      module Validators
        class TypeValidator < Base
          ALLOWED_TYPES = %i[integer string object array datetime].freeze

          def validate_schema!
            return if ALLOWED_TYPES.include?(attribute_type)

            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Unknown type '#{attribute_type}' for attribute '#{attribute_name}'. " \
                  "Allowed types: #{ALLOWED_TYPES.join(', ')}"
          end

          def validate_value!(value) # rubocop:disable Metrics/MethodLength
            return if value.nil? # Type validation doesn't check for nil, required does.

            case attribute_type
            when :integer
              validate_integer!(value)
            when :string
              validate_string!(value)
            when :object
              validate_object!(value)
            when :array
              validate_array!(value)
            when :datetime
              validate_datetime!(value)
            end
          end

          private

          def validate_integer!(value)
            return if value.is_a?(Integer)

            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Attribute '#{attribute_name}' must be an Integer, got #{value.class}"
          end

          def validate_string!(value)
            return if value.is_a?(String)

            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Attribute '#{attribute_name}' must be a String, got #{value.class}"
          end

          def validate_object!(value)
            return if value.is_a?(Hash)

            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Attribute '#{attribute_name}' must be a Hash (object), got #{value.class}"
          end

          def validate_array!(value)
            return if value.is_a?(Array)

            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Attribute '#{attribute_name}' must be an Array, got #{value.class}"
          end

          def validate_datetime!(value)
            # TODO: It is better to divide it into different methods for each class.
            return if value.is_a?(DateTime) || value.is_a?(Time) || value.is_a?(Date)

            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Attribute '#{attribute_name}' must be a DateTime/Time/Date, got #{value.class}"
          end
        end
      end
    end
  end
end
