# frozen_string_literal: true

# NOTE: No specs because it's a Runtime exception.
module Wrong
  module Posts
    # This treaty intentionally has a conflict to test validation:
    # version is marked as both default and deprecated
    class ConflictsDefaultDeprecatedTreaty < ApplicationTreaty
      version 1, default: true do
        strategy Treaty::Strategy::ADAPTER

        deprecated true # CONFLICT: Cannot be both default and deprecated

        request do
          object :post do
            string :title
          end
        end

        response 200 do
          object :post
        end

        delegate_to(lambda do |params:|
          params
        end)
      end
    end
  end
end
