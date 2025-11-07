# frozen_string_literal: true

module Treaty
  module Context
    module Callable
      def call!(version:, params:)
        context = send(:new)

        _call!(context, version:, params:)
      end

      private

      def _call!(context, version:, params:)
        context.send(
          :_call!,
          version:,
          params:,
          collection_of_versions:
        )
      end
    end
  end
end
