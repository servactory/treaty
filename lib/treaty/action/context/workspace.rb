# frozen_string_literal: true

module Treaty
  module Action
    module Context
      module Workspace
        private

        def _call!(
          context:,
          inventory:,
          version:,
          params:,
          collection_of_versions:
        )
          call!(
            context:,
            inventory:,
            version:,
            params:,
            collection_of_versions:
          )
        end

        def call!(
          collection_of_versions:,
          **
        )
          @collection_of_versions = collection_of_versions
        end
      end
    end
  end
end
