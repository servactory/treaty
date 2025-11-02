# frozen_string_literal: true

module Gate
  module API
    module Users
      class InvalidVersionMethodTreaty < ApplicationTreaty
        version 1 do # Also supported: 1.0, 1.0.0.rc1
          strategy Treaty::Strategy::ADAPTER

          fake :action

          # Anything below doesn't matter.

          # ...
        end
      end
    end
  end
end
