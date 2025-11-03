# frozen_string_literal: true

# TODO: This is a prototype, this class is not used.
module Treaty
  module Attribute
    module Validation
      module Orchestrator
        class Response < Base
          private

          def validate_schemas!
            return unless version_factory.response_factory

            version_factory.response_factory.collection_of_scopes.each do |scope_factory| # rubocop:disable Lint/UnreachableLoop
              validate_scope_schemas!(scope_factory)

              # Only validate the first scope for response.
              break
            end
          end

          def validate_values!
            return unless version_factory.response_factory

            version_factory.response_factory.collection_of_scopes.each do |scope_factory| # rubocop:disable Lint/UnreachableLoop
              validate_scope_values!(scope_factory, data)

              # Only validate the first scope for response.
              break
            end
          end
        end
      end
    end
  end
end
