# frozen_string_literal: true

module Treaty
  module Attribute
    module Validation
      module Orchestrator
        class Request < Base
          private

          def collection_of_scopes
            return Request::Scope::Collection.new if version_factory.request_factory.nil?

            version_factory.request_factory.collection_of_scopes
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
