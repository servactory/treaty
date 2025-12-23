# frozen_string_literal: true

module Treaty
  module Action
    module Context
      # Class methods for calling treaty actions.
      #
      # ## Purpose
      #
      # Provides the public `call!` class method that serves as the entry
      # point for treaty execution. Handles instance creation and delegates
      # to instance methods.
      #
      # ## Usage
      #
      # Extended into:
      # - Treaty classes (via Context::DSL)
      #
      # Called by:
      # - Controller integration
      # - Direct treaty invocation in tests
      #
      # ## Call Pattern
      #
      # ```ruby
      # # Public API:
      # result = Posts::CreateTreaty.call!(
      #   version: "1",
      #   params: { post: { title: "Hello" } },
      #   context: controller,      # optional
      #   inventory: inventory      # optional
      # )
      #
      # result.data    # => validated response hash
      # result.status  # => HTTP status code
      # result.version # => resolved version
      # ```
      #
      # ## Implementation
      #
      # Creates a new treaty instance and delegates to `_call!` which
      # passes through to Workspace, then to Versions::Workspace for
      # actual execution.
      module Callable
        # Executes treaty with given parameters
        #
        # Main entry point for treaty execution. Creates instance
        # and delegates to instance methods for actual work.
        #
        # @param version [String, nil] Requested API version (nil uses default)
        # @param params [Hash] Request parameters
        # @param context [Object, nil] Controller context (for inventory evaluation)
        # @param inventory [Treaty::Action::Inventory::Collection, nil] Inventory items
        # @return [Treaty::Action::Result] Execution result
        # @raise [Treaty::Exceptions::VersionNotFound] If version not found
        # @raise [Treaty::Exceptions::Validation] If validation fails
        # @raise [Treaty::Exceptions::Execution] If service execution fails
        def call!(version:, params:, context: nil, inventory: nil)
          treaty_instance = send(:new)

          _call!(treaty_instance, context:, inventory:, version:, params:)
        end

        private

        # Internal call delegation to instance
        #
        # Passes all parameters plus class-level collection_of_versions
        # to the instance's _call! method.
        #
        # @param treaty_instance [Object] Treaty instance
        # @param context [Object, nil] Controller context
        # @param inventory [Treaty::Action::Inventory::Collection, nil] Inventory items
        # @param version [String, nil] Requested version
        # @param params [Hash] Request parameters
        # @return [Treaty::Action::Result] Execution result
        def _call!(treaty_instance, context:, inventory:, version:, params:)
          treaty_instance.send(
            :_call!,
            context:,
            inventory:,
            version:,
            params:,
            collection_of_versions:
          )
        end
      end
    end
  end
end
