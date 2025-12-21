# frozen_string_literal: true

module Posts
  module Create
    class RequestEntity < ApplicationEntity
      object :post do
        string :title, transform: ->(value:) { value.strip }
        string :summary
        string :description, :optional
        string :content

        datetime :published_at, :optional, cast: :string

        boolean :featured, :optional, cast: :integer

        array :tags, :optional do
          string :_self
        end

        object :author do
          string :name
          string :bio

          array :socials, :optional do
            string :provider
            string :value, as: :handle
          end
        end
      end
    end
  end
end
