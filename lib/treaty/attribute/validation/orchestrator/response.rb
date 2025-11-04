# frozen_string_literal: true

# TODO: This is a prototype, this class is not used.
module Treaty
  module Attribute
    module Validation
      module Orchestrator
        class Response < Base
          private

          def collection_of_scopes
            return Response::Scope::Collection.new if version_factory.response_factory.nil?

            # Only validate the first scope for response.
            [version_factory.response_factory.collection_of_scopes.first].compact
          end

          def scope_data_for(name)
            # If the scope is :_self, it's the root level.
            return data if name == :_self

            # Otherwise, fetch data from the named scope.
            data.fetch(name, {})
          end
        end
      end
    end
  end
end
