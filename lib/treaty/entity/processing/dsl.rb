# frozen_string_literal: true

module Treaty
  class Entity
    module Processing
      # DSL module for Entity processing.
      # Includes Processing::Workspace for validation and transformation logic.
      #
      # Follows the Treaty::Versions::DSL pattern.
      module DSL
        def self.included(base)
          base.include(Workspace)
        end
      end
    end
  end
end
