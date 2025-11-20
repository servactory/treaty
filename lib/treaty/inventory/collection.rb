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
    # - Controller::DSL (to pass inventory to treaty execution)
    #
    # ## Methods
    #
    # Delegates common collection methods to internal Set:
    # - `<<` - Add inventory item
    # - `each`, `map`, `select`, `reject` - Iteration
    # - `find`, `first` - Access
    # - `size`, `empty?` - Size checks
    # - `to_h` - Convert to hash
    #
    # Custom methods:
    # - `exists?` - Returns true if collection is not empty
    # - `evaluate` - Evaluates all inventory items with controller context
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

      def_delegators :@collection, :<<, :empty?

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
    end
  end
end
