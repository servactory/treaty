# frozen_string_literal: true

module Treaty
  module Versions
    module Workspace
      private

      def call!(controller:, **) # rubocop:disable Metrics/MethodLength
        super

        version_factory = Resolver.resolve!(
          controller:,
          collection_of_versions: @collection_of_versions
        )

        validated_params = Attribute::Validation::Request.validate!(
          controller:,
          version_factory:
        )

        Execution::Request.execute!(
          version_factory:,
          validated_params:
        )

        # TODO: Call response service here.
      end
    end
  end
end
