# frozen_string_literal: true

module Serialization
  module Gate
    module API
      module Posts
        class IndexDto < ApplicationDto
          array :posts do
            string :id
            string :title
            string :summary
            string :description
            string :content
          end

          object :meta do
            integer :count
            integer :page
            integer :limit, default: 12
          end
        end
      end
    end
  end
end
