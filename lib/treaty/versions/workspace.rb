# frozen_string_literal: true

module Treaty
  module Versions
    module Workspace
      private

      def call!(controller:, params:, **) # rubocop:disable Metrics/MethodLength
        super

        version_factory = Resolver.resolve!(
          controller:,
          collection_of_versions: @collection_of_versions
        )

        validated_params = Request::Attribute::Validator.validate!(
          params:,
          version_factory:
        )

        executor_result = Execution::Request.execute!(
          version_factory:,
          validated_params:
        )

        validated_response = Response::Attribute::Validator.validate!(
          version_factory:,
          response_data: executor_result
        )

        status = version_factory.response_factory&.status || 200

        Treaty::Result.new(
          data: validated_response,
          status:
        )
      end
    end
  end
end
