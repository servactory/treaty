# frozen_string_literal: true

module Posts
  module Create
    class ResponseEntity < ApplicationEntity
      object :post do
        string :id
        string :title
        string :summary
        string :description
        string :content

        datetime :published_at, cast: :string

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

        time :created_at, cast: :integer
        time :updated_at, cast: :string
      end
    end
  end
end
