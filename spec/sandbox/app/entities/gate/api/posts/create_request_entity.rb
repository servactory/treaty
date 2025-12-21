# frozen_string_literal: true

module Gate
  module API
    module Posts
      # Request entity for Posts#create - post creation params
      class CreateRequestEntity < ApplicationEntity
        object :post do
          string :title, transform: ->(value:) { value.strip }
          string :summary
          string :description, :optional
          string :content

          # Example: cast ISO8601 string to datetime object
          string :published_at, :optional, cast: :datetime

          # Example: cast string to boolean
          string :featured, :optional, cast: :boolean

          array :tags, :optional do
            string :_self, transform: ->(value:) { value.downcase }
          end

          object :author do
            string :name
            string :bio

            array :socials, :optional do
              string :provider, in: %w[twitter linkedin github]
              string :handle, as: :value
            end
          end
        end
      end
    end
  end
end
