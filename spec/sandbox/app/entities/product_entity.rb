# frozen_string_literal: true

class ProductEntity < ApplicationEntity
  object :product do
    string :id
    string :name
    string :description, :optional

    integer :price_cents
    string :currency, default: { is: "USD" }

    string :status, in: %w[draft active discontinued]

    integer :stock_count, if: ->(product:) { product[:status] == "active" }
    datetime :published_at, :optional, cast: :string, if: ->(product:) { product[:status] == "active" }

    string :sku, unless: ->(product:) { product[:status] == "draft" }
    array :tags, :optional, unless: ->(product:) { product[:status] == "draft" } do
      string :_self
    end

    string :admin_notes, :optional, if: ->(product:) { product[:status] == "draft" }

    string :discontinued_reason, :optional, if: ->(product:) { product[:status] == "discontinued" }

    object :manufacturer, :optional, unless: ->(product:) { product[:status] == "discontinued" } do
      string :name
      string :country, :optional
    end

    time :created_at, cast: :string
    time :updated_at, cast: :string
  end
end