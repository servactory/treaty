# frozen_string_literal: true

# OrderEntity demonstrates computed attributes in Entity context.
class OrderEntity < ApplicationEntity
  object :order do
    string :id
    string :customer_name

    # Line items with computed line totals
    array :items do
      string :product_name
      integer :quantity
      integer :unit_price_cents

      # Computed: line total from quantity * unit_price
      integer :line_total_cents, computed: (lambda do |**attributes|
        # Access parent array element data
        # In array context, attributes will contain the item data
        quantity = attributes.dig(:order, :items)&.last&.dig(:quantity) || 0
        unit_price = attributes.dig(:order, :items)&.last&.dig(:unit_price_cents) || 0
        quantity.to_i * unit_price.to_i
      end)
    end

    # Order-level computed fields
    integer :subtotal_cents, computed: (lambda do |**attributes|
      items = attributes.dig(:order, :items) || []
      items.sum { |item| item[:quantity].to_i * item[:unit_price_cents].to_i }
    end)

    integer :tax_rate_percent, default: 10

    integer :tax_cents, computed: (lambda do |**attributes|
      items = attributes.dig(:order, :items) || []
      subtotal = items.sum { |item| item[:quantity].to_i * item[:unit_price_cents].to_i }
      tax_rate = attributes.dig(:order, :tax_rate_percent) || 10
      (subtotal * tax_rate / 100.0).round
    end)

    integer :total_cents, computed: (lambda do |**attributes|
      items = attributes.dig(:order, :items) || []
      subtotal = items.sum { |item| item[:quantity].to_i * item[:unit_price_cents].to_i }
      tax_rate = attributes.dig(:order, :tax_rate_percent) || 10
      tax = (subtotal * tax_rate / 100.0).round
      subtotal + tax
    end)

    # Computed: formatted total as string
    string :formatted_total, computed: (lambda do |**attributes|
      items = attributes.dig(:order, :items) || []
      subtotal = items.sum { |item| item[:quantity].to_i * item[:unit_price_cents].to_i }
      tax_rate = attributes.dig(:order, :tax_rate_percent) || 10
      tax = (subtotal * tax_rate / 100.0).round
      total = subtotal + tax
      "$#{format('%.2f', total / 100.0)}"
    end)

    time :created_at, cast: :string
  end
end
