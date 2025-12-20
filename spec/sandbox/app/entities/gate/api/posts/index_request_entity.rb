# frozen_string_literal: true

module Gate
  module API
    module Posts
      # Request entity for Posts#index - filters and pagination
      class IndexRequestEntity < ApplicationEntity
        object :filters, :optional do
          string :title, :optional, transform: ->(value:) { value.strip.downcase }
          string :summary, :optional
          string :description, :optional
        end
      end
    end
  end
end
