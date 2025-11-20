# frozen_string_literal: true

module Treaty
  module Context
    module Workspace
      private

      def _call!(
        inventory:,
        controller_context:,
        version:,
        params:,
        collection_of_versions:
      )
        call!(
          inventory:,
          controller_context:,
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
