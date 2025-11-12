# frozen_string_literal: true

module Treaty
  module Info
    module Entity
      class Result
        attr_reader :attributes

        def initialize(builder)
          @attributes = builder.attributes
        end
      end
    end
  end
end
