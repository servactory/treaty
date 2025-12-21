# frozen_string_literal: true

module Posts
  module Index
    class ResponseEntity < ApplicationEntity
      array :posts do
        string :id
        string :title
        string :summary
        string :description
        string :content

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
