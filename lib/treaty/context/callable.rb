# frozen_string_literal: true

module Treaty
  module Context
    module Callable
      def call!(version:, params:, inventory: nil, context: nil)
        treaty_instance = send(:new)

        _call!(treaty_instance, inventory:, context:, version:, params:)
      end

      private

      def _call!(treaty_instance, inventory:, context:, version:, params:)
        treaty_instance.send(
          :_call!,
          inventory:,
          context:,
          version:,
          params:,
          collection_of_versions:
        )
      end
    end
  end
end
