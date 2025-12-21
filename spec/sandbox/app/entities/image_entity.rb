# frozen_string_literal: true

# Unified ImageEntity combining attributes from Deserialization and Serialization DTOs.
# Use with .call(data, required: true) for request validation (strict)
# Use with .call(data, required: false) for response serialization (lenient)
class ImageEntity < ApplicationEntity
  object :image do
    # Example: required with custom string message
    string :url, required: { is: true, message: "Image URL is mandatory" }

    string :alt, :optional

    # Response-only: inclusion with custom string message
    string :format,
           :optional,
           in: %w[jpg png gif webp]

    # Response-only: inclusion with custom lambda message (advanced mode)
    string :size,
           :optional,
           inclusion: {
             in: %w[small medium large],
             message: lambda do |attribute:, value:, allowed_values:, **|
               "Invalid #{attribute}: '#{value}'. Must be one of: #{allowed_values.join(', ')}"
             end
           },
           default: { is: "medium" }

    integer :width, :optional
    integer :height, :optional
  end
end
