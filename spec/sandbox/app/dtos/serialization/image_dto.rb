# frozen_string_literal: true

module Serialization
  class ImageDto < ApplicationDto
    object :image do
      # Example: required with custom string message
      string :url, required: { is: true, message: "Image URL is mandatory" }

      string :alt, :optional

      # Example: inclusion with custom string message
      string :format,
             in: %w[jpg png gif webp],
             required: { is: true, message: "Format must be specified" }

      # Example: inclusion with custom lambda message (advanced mode)
      string :size,
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
end
