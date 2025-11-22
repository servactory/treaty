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

            # Demonstrates casting datetime to string (ISO8601)
            datetime :published_at, cast: :string

            # Demonstrates casting boolean to integer
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

            # Demonstrates casting datetime to integer (Unix timestamp)
            datetime :created_at, cast: :integer
            # Demonstrates casting datetime to string
            datetime :updated_at, cast: :string
          end
        end
      end
    end
  end
end
