# frozen_string_literal: true

module Treaty
  class Entity
    module Context
      # Base workspace for Entity processing.
      # Provides _call! entry point and delegates to call!.
      #
      # Uses keyword argument `incoming_arguments:` for internal consistency.
      #
      # Follows the Treaty::Context::Workspace pattern.
      # Processing::Workspace will chain via super.
      module Workspace
        private

        def _call!(incoming_arguments:, preset: nil)
          call!(incoming_arguments:, preset:)
        end

        def call!(incoming_arguments:, preset: nil)
          @incoming_arguments = incoming_arguments
          @preset = preset
        end
      end
    end
  end
end
