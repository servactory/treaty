# frozen_string_literal: true

module Treaty
  module Versions
    module Workspace
      private

      def call!(controller:, **)
        super

        version_factory = Resolver.resolve!(
          controller:,
          collection_of_versions: @collection_of_versions
        )

        Attribute::Validation::Request.validate!(
          controller:,
          version_factory:
        )

        # TODO: Call executor service here.

        # TODO: Call response service here.
      end
    end
  end
end
