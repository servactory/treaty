# frozen_string_literal: true

# ProductEntity demonstrates conditional attributes with both if and unless options.
class ProductEntity < ApplicationEntity
  object :product do
    string :id
    string :name
    string :description, :optional

    # Price and currency
    integer :price_cents
    string :currency, default: { is: "USD" }

    # Status field determines visibility of other attributes
    string :status, in: %w[draft active discontinued]

    # Using 'if' conditional - include only for active products
    integer :stock_count, if: ->(product:) { product[:status] == "active" }
    datetime :published_at, :optional, cast: :string, if: ->(product:) { product[:status] == "active" }

    # Using 'unless' conditional - exclude for draft products
    string :sku, unless: ->(product:) { product[:status] == "draft" }
    array :tags, :optional, unless: ->(product:) { product[:status] == "draft" } do
      string :_self
    end

    # Admin notes only for drafts
    string :admin_notes, :optional, if: ->(product:) { product[:status] == "draft" }

    # Discontinued reason only for discontinued products
    string :discontinued_reason, :optional, if: ->(product:) { product[:status] == "discontinued" }

    # Manufacturer info excluded for discontinued products
    object :manufacturer, :optional, unless: ->(product:) { product[:status] == "discontinued" } do
      string :name
      string :country, :optional
    end

    time :created_at, cast: :string
    time :updated_at, cast: :string
  end
end
