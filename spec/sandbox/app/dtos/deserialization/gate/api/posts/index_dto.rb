# frozen_string_literal: true

module Deserialization
  module Gate
    module API
      module Posts
        class IndexDto < ApplicationDto
          object :filters, :optional do
            string :title, :optional, transform: ->(value:) { value.strip.downcase }
            string :summary, :optional
            string :description, :optional
          end
        end
      end
    end
  end
end
