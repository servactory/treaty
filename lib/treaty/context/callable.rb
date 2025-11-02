# frozen_string_literal: true

module Treaty
  module Context
    module Callable
      def call!(controller:, params:)
        context = send(:new)

        _call!(context, controller:, params:)
      end

      private

      def _call!(context, controller:, params:)
        context.send(
          :_call!,
          controller:,
          params:,
          collection_of_versions:
        )
      end
    end
  end
end
