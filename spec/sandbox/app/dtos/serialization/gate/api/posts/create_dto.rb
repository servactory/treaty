# frozen_string_literal: true

module Serialization
  module Gate
    module API
      module Posts
        class CreateDto < ApplicationDto
          object :post do
            string :id
            string :title
            string :summary
            string :description
            string :content

            # Example: cast datetime to ISO8601 string for API response
            datetime :published_at, cast: :string

            # Example: cast boolean to integer representation
            boolean :featured, cast: :integer

            array :tags do
              string :_self
            end

            object :author do
              string :name
              string :bio

              array :socials do
                string :provider
                string :value, as: :handle
              end
            end

            integer :rating
            integer :views

            # Example: cast time to Unix timestamp for efficient transfer
            time :created_at, cast: :integer
            time :updated_at, cast: :string
          end
        end
      end
    end
  end
end
