# frozen_string_literal: true

module Treaty
  module Attribute
    module Validation
      module Orchestrator
        class Base
          attr_reader :version_factory, :data

          def self.validate!(...)
            new(...).validate!
          end

          def initialize(version_factory:, data: {})
            @version_factory = version_factory
            @data = data
          end

          def validate!
            return unless version_factory.strategy_instance.adapter?

            validate_schemas!

            validate_values! unless data.empty?
          end

          private

          def validate_schemas!
            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Subclass must implement the validate_schemas! method"
          end

          def validate_values!
            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Subclass must implement the validate_values! method"
          end

          def validate_scope_schemas!(scope_factory)
            scope_factory.collection_of_attributes.each do |attribute|
              validator = AttributeValidator.new(attribute)
              validator.validate_schema!
            end
          end

          def validate_scope_values!(scope_factory, scope_data)
            scope_factory.collection_of_attributes.each do |attribute|
              validator = AttributeValidator.new(attribute)

              value = scope_data[attribute.name]
              validator.validate_value!(value)
            end
          end
        end
      end
    end
  end
end
