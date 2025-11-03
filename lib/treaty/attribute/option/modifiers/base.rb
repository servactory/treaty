# frozen_string_literal: true

module Treaty
  module Attribute
    module Option
      module Modifiers
        class Base
          attr_reader :attribute_name, :attribute_type, :option_schema

          def initialize(attribute_name:, attribute_type:, option_schema:)
            @attribute_name = attribute_name
            @attribute_type = attribute_type
            @option_schema = option_schema
          end

          def validate_schema!
            # TODO: Add a specialized class to Treaty::Exceptions.
            # TODO: It is necessary to implement a translation system (I18n).
            raise NotImplementedError, "Subclasses must implement validate_schema!"
          end

          def apply!(value)
            # TODO: Add a specialized class to Treaty::Exceptions.
            # TODO: It is necessary to implement a translation system (I18n).
            raise NotImplementedError, "Subclasses must implement apply!"
          end
        end
      end
    end
  end
end
