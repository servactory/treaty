# frozen_string_literal: true

module Treaty
  module Versions
    module Workspace
      private

      def call!(controller:, **)
        super

        # TODO: Current version
        # Example: 1, 1.0, 1.0.0, 1.0.0.rc1
        # Treaty::Engine.config.treaty.version.call(controller).segments.inspect

        nil # delete me
      end
    end
  end
end
