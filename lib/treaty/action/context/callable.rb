# frozen_string_literal: true

module Treaty
  module Action
    module Context
      module Callable
        def call!(version:, params:, context: nil, inventory: nil)
          treaty_instance = send(:new)

          _call!(treaty_instance, context:, inventory:, version:, params:)
        end

        private

        def _call!(treaty_instance, context:, inventory:, version:, params:)
          treaty_instance.send(
            :_call!,
            context:,
            inventory:,
            version:,
            params:,
            collection_of_versions:
          )
        end
      end
    end
  end
end
