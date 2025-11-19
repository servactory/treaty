# frozen_string_literal: true

# NOTE: No specs because it's a Runtime exception.
module Wrong
  module Posts
    # This treaty intentionally has a conflict to test validation:
    # multiple versions are marked as default
    class ConflictsMultipleDefaultsTreaty < ApplicationTreaty
      version 1, default: true do
        strategy Treaty::Strategy::DIRECT

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

      version 2, default: true do # CONFLICT: Second default version
        strategy Treaty::Strategy::DIRECT

        request do
          object :post do
            string :title
            string :content
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
