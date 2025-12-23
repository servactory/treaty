# frozen_string_literal: true

module Treaty
  module Action
    module Inventory
      # Collection wrapper for sets of inventory items.
      #
      # ## Purpose
      #
      # Provides a unified interface for working with collections of inventory items.
      # Uses Ruby Set internally for uniqueness but exposes Array-like interface.
      #
      # ## Usage
      #
      # Used internally by:
      # - Inventory::Factory (to store inventory items)
      # - Executor::Inventory (to evaluate and access items)
      #
      # ## Methods
      #
      # Delegates common collection methods to internal Set:
      # - `<<` - Add inventory item
      # - `each_with_object` - Iteration with accumulator
      # - `find` - Access by condition
      # - `empty?` - Size check
      #
      # Custom methods:
      # - `exists?` - Returns true if collection is not empty
      # - `names` - Returns array of inventory item names
      # - `evaluate` - Evaluates all items with controller context
      #
      # ## Example
      #
      #   collection = Collection.new
      #   collection << Inventory.new(name: :current_user, source: :current_user)
      #   collection << Inventory.new(name: :posts, source: :load_posts)
      #   collection.exists?  # => true
      #   collection.names    # => [:current_user, :posts]
      class Collection
        extend Forwardable

        def_delegators :@collection, :<<, :each_with_object, :find, :empty?

        # Creates a new collection instance
        #
        # @param collection [Set] Initial collection (default: empty Set)
        def initialize(collection = Set.new)
          @collection = collection
        end

        # Checks if collection has any elements
        #
        # @return [Boolean] True if collection is not empty
        def exists?
          !empty?
        end

        # Returns array of all inventory item names
        #
        # @return [Array<Symbol>] Array of inventory item names
        def names
          @collection.each_with_object([]) { |item, names| names << item.name }
        end

        # Evaluates all inventory items with controller context
        #
        # @param context [Object] Controller context for evaluation
        # @return [Hash{Symbol => Object}] Hash of evaluated inventory values
        def evaluate(context)
          @collection.each_with_object({}) do |inventory_item, hash|
            hash[inventory_item.name] = inventory_item.evaluate(context)
          end
        end
      end
    end
  end
end
