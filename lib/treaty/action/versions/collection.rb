# frozen_string_literal: true

module Treaty
  module Action
    module Versions
      class Collection
        extend Forwardable

        def_delegators :@collection, :<<, :map, :find

        def initialize(collection = Set.new)
          @collection = collection
        end
      end
    end
  end
end
