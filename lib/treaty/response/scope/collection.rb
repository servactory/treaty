# frozen_string_literal: true

module Treaty
  module Response
    module Scope
      class Collection
        extend Forwardable

        def_delegators :@collection, :<<, :to_h

        def initialize(collection = Set.new)
          @collection = collection
        end
      end
    end
  end
end
