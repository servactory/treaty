# frozen_string_literal: true

module Treaty
  module Versions
    module Workspace
      private

      def call!(controller:, **)
        super

        # TODO: It is necessary to implement global access to the
        #       current version within the context.
        current_version = current_version_from(controller)

        Attribute::Validation::Request.validate!(
          controller:,
          current_version:,
          collection_of_versions: @collection_of_versions
        )

        # TODO: Call executor service here.

        # TODO: Call response service here.
      end

      def current_version_from(controller)
        Treaty::Engine.config.treaty.version.call(controller)
      end
    end
  end
end
