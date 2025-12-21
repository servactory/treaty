# frozen_string_literal: true

class ImageEntity < ApplicationEntity
  object :image do
    string :url, required: { is: true, message: "Image URL is mandatory" }

    string :alt, :optional

    string :format,
           in: %w[jpg png gif webp],
           required: { is: true, message: "Format must be specified" }

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
