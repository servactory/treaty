# frozen_string_literal: true

module Treaty
  module Versions
    module Workspace
      private

      def call!(controller:, **)
        super

        current_version = current_version_from(controller)

        Attribute::Validation::Request.validate!(
          controller:,
          current_version:,
          collection_of_versions: @collection_of_versions
        )
      end

      def current_version_from(controller)
        Treaty::Engine.config.treaty.version.call(controller)
      end
    end
  end
end
