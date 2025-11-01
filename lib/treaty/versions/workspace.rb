# frozen_string_literal: true

module Treaty
  module Versions
    module Workspace
      private

      def call!(controller:, **)
        super

        # TODO: Current version
        # Treaty::Engine.config.treaty.version.call(controller)

        nil # delete me
      end
    end
  end
end
