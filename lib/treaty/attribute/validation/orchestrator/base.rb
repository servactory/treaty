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
            return data unless version_factory.strategy_instance.adapter?

            collection_of_scopes.each do |scope_factory|
              validate_scope!(scope_factory)
            end

            data
          end

          private

          def collection_of_scopes
            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Validation,
                  "Subclass must implement the collection_of_scopes method"
          end

          def validate_scope!(scope_factory)
            scope_data = scope_data_for(scope_factory.name)

            validators_for_scope(scope_factory).each do |attribute, validator|
              value = scope_data.fetch(attribute.name, nil)
              validator.validate_value!(value)
            end
          end

          def validators_for_scope(scope_factory)
            @validators_cache ||= {}
            @validators_cache[scope_factory] ||= build_validators_for_scope(scope_factory)
          end

          def build_validators_for_scope(scope_factory)
            scope_factory.collection_of_attributes.each_with_object({}) do |attribute, cache|
              validator = AttributeValidator.new(attribute)
              validator.validate_schema!
              cache[attribute] = validator
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
