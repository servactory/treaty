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

            collection_of_scopes.each do |scope_factory|
              validate_scope!(scope_factory)
            end
          end

          private

          def collection_of_scopes
            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Subclass must implement the collection_of_scopes method"
          end

          def validate_scope!(scope_factory)
            scope_data = data.empty? ? nil : scope_data_for(scope_factory.name)

            scope_factory.collection_of_attributes.each do |attribute|
              validator = AttributeValidator.new(attribute)
              validator.validate_schema!

              next if scope_data.nil?

              value = scope_data.fetch(attribute.name, nil)
              validator.validate_value!(value)
            end
          end

          def scope_data_for(_name)
            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Subclass must implement the scope_data_for method"
          end
        end
      end
    end
  end
end
