# frozen_string_literal: true

module Treaty
  module Info
    module Rest
      class Result
        attr_reader :versions

        def initialize(builder)
          @versions = builder.versions
        end
      end
    end
  end
end
