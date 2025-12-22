# frozen_string_literal: true

module Treaty
  module Entity
    module Info
      class Result
        attr_reader :attributes

        def initialize(builder)
          @attributes = builder.attributes
        end
      end
    end
  end
end
