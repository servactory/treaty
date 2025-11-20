# frozen_string_literal: true

module Treaty
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
    # - Inventory::Factory (to store inventory items during DSL processing)
    #
    # ## Methods
    #
    # Delegates common collection methods to internal Set:
    # - `<<` - Add inventory item
    # - `empty?` - Check if collection is empty
    #
    # Custom methods:
    # - `exists?` - Returns true if collection is not empty
    # - `evaluate` - Evaluates all inventory items with context
    #
    # ## Example
    #
    #   collection = Collection.new
    #   collection << Inventory.new(name: :posts, source: :load_posts)
    #   collection << Inventory.new(name: :meta, source: -> { { count: 10 } })
    #   collection.size  # => 2
    #   collection.exists?  # => true
    class Collection
      extend Forwardable

      def_delegators :@collection, :<<, :empty?, :each_with_object

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

      # Evaluates all inventory items with the given context
      #
      # @param context [Object] The controller instance to call methods on
      # @return [Hash{Symbol => Object}] Hash of inventory name => resolved value
      def evaluate(context)
        @collection.each_with_object({}) do |inventory_item, hash|
          hash[inventory_item.name] = inventory_item.evaluate(context)
        end
      end
    end
  end
end
