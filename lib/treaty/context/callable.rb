# frozen_string_literal: true

module Treaty
  module Context
    module Callable
      def call!(inventory:, version:, params:)
        context = send(:new)

        _call!(context, inventory:, version:, params:)
      end

      private

      def _call!(context, inventory:, version:, params:)
        context.send(
          :_call!,
          inventory:,
          version:,
          params:,
          collection_of_versions:
        )
      end
    end
  end
end
