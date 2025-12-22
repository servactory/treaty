# frozen_string_literal: true

module Treaty
  module Action
    module Inventory
      class Collection
        extend Forwardable

        def_delegators :@collection, :<<, :each_with_object, :find, :empty?

        def initialize(collection = Set.new)
          @collection = collection
        end

        def exists?
          !empty?
        end

        def names
          @collection.each_with_object([]) { |item, names| names << item.name }
        end

        def evaluate(context)
          @collection.each_with_object({}) do |inventory_item, hash|
            hash[inventory_item.name] = inventory_item.evaluate(context)
          end
        end
      end
    end
  end
end
