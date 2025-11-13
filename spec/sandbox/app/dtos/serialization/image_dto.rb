# frozen_string_literal: true

module Serialization
  class ImageDto < ApplicationDto
    object :image do
      string :url
      string :alt, :optional
      integer :width, :optional
      integer :height, :optional
    end
  end
end
