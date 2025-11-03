# frozen_string_literal: true

module Treaty
  module Response
    module Scope
      class Collection
        extend Forwardable

        def_delegators :@collection, :<<, :to_h, :each, :find, :empty?

        def initialize(collection = Set.new)
          @collection = collection
        end

        def exists?
          !empty?
        end
      end
    end
  end
end
