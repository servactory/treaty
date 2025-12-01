# frozen_string_literal: true

module Serialization
  # Demonstrates computed attributes in Entity/DTO context
  class OrderDto < ApplicationDto
    object :order do
      string :id
      string :customer_name

      # Line items with computed line totals
      array :items do
        string :product_name
        integer :quantity
        integer :unit_price_cents

        # Computed: line total from quantity * unit_price
        integer :line_total_cents, computed: lambda { |**attrs|
          # Access parent array element data
          # In array context, attrs will contain the item data
          quantity = attrs.dig(:order, :items)&.last&.dig(:quantity) || 0
          unit_price = attrs.dig(:order, :items)&.last&.dig(:unit_price_cents) || 0
          quantity.to_i * unit_price.to_i
        }
      end

      # Order-level computed fields
      integer :subtotal_cents, computed: lambda { |**attrs|
        items = attrs.dig(:order, :items) || []
        items.sum { |item| item[:quantity].to_i * item[:unit_price_cents].to_i }
      }

      integer :tax_rate_percent, default: 10

      integer :tax_cents, computed: lambda { |**attrs|
        items = attrs.dig(:order, :items) || []
        subtotal = items.sum { |item| item[:quantity].to_i * item[:unit_price_cents].to_i }
        tax_rate = attrs.dig(:order, :tax_rate_percent) || 10
        (subtotal * tax_rate / 100.0).round
      }

      integer :total_cents, computed: lambda { |**attrs|
        items = attrs.dig(:order, :items) || []
        subtotal = items.sum { |item| item[:quantity].to_i * item[:unit_price_cents].to_i }
        tax_rate = attrs.dig(:order, :tax_rate_percent) || 10
        tax = (subtotal * tax_rate / 100.0).round
        subtotal + tax
      }

      # Computed: formatted total as string
      string :formatted_total, computed: lambda { |**attrs|
        items = attrs.dig(:order, :items) || []
        subtotal = items.sum { |item| item[:quantity].to_i * item[:unit_price_cents].to_i }
        tax_rate = attrs.dig(:order, :tax_rate_percent) || 10
        tax = (subtotal * tax_rate / 100.0).round
        total = subtotal + tax
        "$#{format('%.2f', total / 100.0)}"
      }

      time :created_at, cast: :string
    end
  end
end
