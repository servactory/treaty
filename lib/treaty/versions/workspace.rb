# frozen_string_literal: true

module Treaty
  module Versions
    module Workspace
      private

      def call!(context:, inventory:, version:, params:, **) # rubocop:disable Metrics/MethodLength
        super

        version_factory = Resolver.resolve!(
          specified_version: version,
          collection_of_versions: @collection_of_versions
        )

        validated_params = Request::Validator.validate!(
          params:,
          version_factory:
        )

        executor_result = Execution::Request.execute!(
          context:,
          inventory:,
          version_factory:,
          validated_params:
        )

        validated_response = Response::Validator.validate!(
          version_factory:,
          response_data: executor_result
        )

        status = version_factory.response_factory&.status || 200

        Treaty::Result.new(
          data: validated_response,
          status:,
          version: version_factory.version.version
        )
      end
    end
  end
end
