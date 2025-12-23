# frozen_string_literal: true

module Treaty
  module Action
    module Context
      # Instance methods for treaty execution context.
      #
      # ## Purpose
      #
      # Provides instance-level methods that bridge between Callable
      # (class methods) and Versions::Workspace (actual execution).
      # Stores the collection_of_versions in instance variable for
      # use by Versions::Workspace.
      #
      # ## Usage
      #
      # Included via:
      # - Context::DSL (when DSL is included)
      #
      # ## Method Chain
      #
      # ```
      # Callable.call! (class)
      #   │
      #   └─► _call! (receives all params from class)
      #         │
      #         └─► call! (stores @collection_of_versions)
      #               │
      #               └─► super → Versions::Workspace.call!
      # ```
      #
      # ## Why Two Methods?
      #
      # - `_call!` - Entry point from Callable, receives raw parameters
      # - `call!` - Stores collection_of_versions, then calls super
      #
      # The separation allows Versions::Workspace to override `call!`
      # while keeping the parameter passing clean.
      #
      # ## Instance Variable
      #
      # Stores `@collection_of_versions` which is used by
      # Versions::Workspace.call! for version resolution.
      module Workspace
        private

        # Entry point for instance execution
        #
        # Receives all parameters from Callable and forwards to call!.
        # This method exists to provide a clean interface between
        # class methods and instance methods.
        #
        # @param context [Object, nil] Controller context
        # @param inventory [Treaty::Action::Inventory::Collection, nil] Inventory items
        # @param version [String, nil] Requested version
        # @param params [Hash] Request parameters
        # @param collection_of_versions [Treaty::Action::Versions::Collection] Version factories
        # @return [Treaty::Action::Result] Execution result
        def _call!(
          context:,
          inventory:,
          version:,
          params:,
          collection_of_versions:
        )
          call!(
            context:,
            inventory:,
            version:,
            params:,
            collection_of_versions:
          )
        end

        # Stores collection and delegates to Versions::Workspace
        #
        # Captures collection_of_versions in instance variable,
        # then calls super which invokes Versions::Workspace.call!
        # for actual treaty execution.
        #
        # @param collection_of_versions [Treaty::Action::Versions::Collection] Version factories
        # @return [Treaty::Action::Result] Execution result (from super)
        def call!(
          collection_of_versions:,
          **
        )
          @collection_of_versions = collection_of_versions
        end
      end
    end
  end
end
