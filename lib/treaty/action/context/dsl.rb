# frozen_string_literal: true

module Treaty
  module Action
    module Context
      # DSL module that wires up callable and workspace functionality.
      #
      # ## Purpose
      #
      # Acts as a composition root that includes both Callable (class methods)
      # and Workspace (instance methods) when included in a treaty class.
      # This enables the `call!` API pattern.
      #
      # ## Usage
      #
      # Included in:
      # - Treaty::Action::Base (as part of core DSL)
      #
      # ## What it provides
      #
      # When included, adds:
      # - Class method: `call!` (from Callable)
      # - Instance methods: `_call!`, `call!` (from Workspace)
      #
      # ## Architecture
      #
      # The call chain works as follows:
      #
      # ```
      # MyTreaty.call!(version:, params:, ...)
      #   │
      #   └─► Callable.call! (class method)
      #         │
      #         ├─► Creates treaty instance
      #         │
      #         └─► Workspace._call! (instance method)
      #               │
      #               └─► Workspace.call! (stores @collection_of_versions)
      #                     │
      #                     └─► super → Versions::Workspace.call!
      # ```
      module DSL
        # Hook called when module is included
        #
        # Extends the including class with Callable (class methods)
        # and includes Workspace (instance methods).
        #
        # @param base [Class] The class including this module
        def self.included(base)
          base.extend(Callable)
          base.include(Workspace)
        end
      end
    end
  end
end
