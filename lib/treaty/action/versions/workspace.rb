# frozen_string_literal: true

module Treaty
  module Action
    module Versions
      # Core execution module for treaty call! method.
      #
      # ## Purpose
      #
      # Provides the `call!` instance method that orchestrates the complete
      # treaty execution flow: version resolution, request validation,
      # service execution, and response validation.
      #
      # ## Usage
      #
      # Included via:
      # - Versions::DSL (when DSL is included in treaty class)
      #
      # Called by:
      # - Controller integration (via Treaty::Action::Base.call!)
      #
      # ## Execution Flow
      #
      # ```
      # call!(context:, inventory:, version:, params:)
      #   │
      #   ├─1─► Resolver.resolve! ──► Find version factory
      #   │
      #   ├─2─► Request::Validator.validate! ──► Validate params
      #   │
      #   ├─3─► Execution::Request.execute! ──► Run service
      #   │
      #   ├─4─► Response::Validator.validate! ──► Validate response
      #   │
      #   └─5─► Result.new ──► Return result object
      # ```
      #
      # ## Parameters
      #
      # | Parameter | Description |
      # |-----------|-------------|
      # | context | Controller instance |
      # | inventory | Inventory::Collection with controller data |
      # | version | Requested version string (or nil for default) |
      # | params | Request parameters |
      #
      # ## Return Value
      #
      # Returns `Treaty::Action::Result` with:
      # - `data` - Validated response hash
      # - `status` - HTTP status code
      # - `version` - Resolved version string
      module Workspace
        private

        # Executes the complete treaty flow
        #
        # Orchestrates version resolution, validation, execution,
        # and returns a Result object.
        #
        # @param context [Object] Controller instance
        # @param inventory [Treaty::Action::Inventory::Collection] Controller data
        # @param version [String, nil] Requested version or nil for default
        # @param params [Hash] Request parameters
        # @return [Treaty::Action::Result] Execution result
        # @raise [Treaty::Exceptions::VersionNotFound] If version not found
        # @raise [Treaty::Exceptions::Deprecated] If version is deprecated
        # @raise [Treaty::Exceptions::Validation] If validation fails
        # @raise [Treaty::Exceptions::Execution] If service execution fails
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

          Result.new(
            data: validated_response,
            status:,
            version: version_factory.version.version
          )
        end
      end
    end
  end
end
