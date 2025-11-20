# frozen_string_literal: true

module Treaty
  module Context
    module Callable
      def call!(version:, params:, inventory: nil, controller_context: nil)
        # Provide default empty inventory collection if not provided
        inventory ||= Treaty::Inventory::Collection.new

        instance = send(:new)

        _call!(instance, inventory:, controller_context:, version:, params:)
      end

      private

      def _call!(instance, inventory:, controller_context:, version:, params:)
        instance.send(
          :_call!,
          inventory:,
          controller_context:,
          version:,
          params:,
          collection_of_versions:
        )
      end
    end
  end
end
