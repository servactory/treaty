# frozen_string_literal: true

module Gate
  module API
    module Posts
      # Response entity for Posts#index - posts list with metadata
      class IndexResponseEntity < ApplicationEntity
        array :posts do
          string :id
          string :title
          string :summary
          string :description
          string :content

          # Example: cast time to string for API response
          time :created_at, cast: :string
        end

        object :meta do
          integer :count
          integer :page
          integer :limit, default: 12
        end
      end
    end
  end
end
