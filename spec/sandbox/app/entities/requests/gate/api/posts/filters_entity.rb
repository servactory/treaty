# frozen_string_literal: true

module Requests
  module Gate
    module API
      module Posts
        class FiltersEntity < ApplicationEntity
          object :filters, :optional do
            string :title, :optional, transform: ->(value:) { value.strip.downcase }
            string :summary, :optional
            string :description, :optional
          end
        end
      end
    end
  end
end