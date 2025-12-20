# frozen_string_literal: true

module Treaty
  class Entity
    module Context
      # DSL module for Entity context.
      # Extends Callable (class methods) and includes Workspace (instance methods).
      #
      # Follows the Treaty::Context::DSL pattern.
      module DSL
        def self.included(base)
          base.extend(Callable)
          base.include(Workspace)
        end
      end
    end
  end
end
