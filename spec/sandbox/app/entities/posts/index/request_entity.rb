# frozen_string_literal: true

module Posts
  module Index
    class RequestEntity < ApplicationEntity
      object :filters, :optional do
        string :title, :optional, transform: ->(value:) { value.strip.downcase }
        string :summary, :optional
        string :description, :optional
      end
    end
  end
end
