# frozen_string_literal: true

module Treaty
  module Attribute
    module Validation
      module Orchestrator
        class Request < Base
          private

          def validate_schemas!
            return unless version_factory.request_factory

            version_factory.request_factory.collection_of_scopes.each do |scope_factory|
              validate_scope_schemas!(scope_factory)
            end
          end

          def validate_values!
            return unless version_factory.request_factory

            version_factory.request_factory.collection_of_scopes.each do |scope_factory|
              scope_data = scope_data_for(scope_factory.name)
              validate_scope_values!(scope_factory, scope_data)
            end
          end

          def scope_data_for(name)
            # If the scope is :self, it's the root level.
            return data if name == :self

            # Otherwise, fetch data from the named scope.
            data.fetch(name, {})
          end
        end
      end
    end
  end
end
