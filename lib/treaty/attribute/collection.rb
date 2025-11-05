# frozen_string_literal: true

require "forwardable"

module Treaty
  module Attribute
    # Collection wrapper for sets of attributes.
    #
    # ## Purpose
    #
    # Provides a unified interface for working with collections of attributes.
    # Uses Ruby Set internally for uniqueness but exposes Array-like interface.
    #
    # ## Usage
    #
    # Used internally by:
    # - Scope factories (to store attributes in a scope)
    # - Attribute::Base (to store nested attributes)
    #
    # ## Methods
    #
    # Delegates common collection methods to internal Set:
    # - `<<` - Add attribute
    # - `each`, `map`, `select`, `reject` - Iteration
    # - `find`, `first` - Access
    # - `size`, `empty?` - Size checks
    # - `to_h` - Convert to hash
    #
    # Custom methods:
    # - `exists?` - Returns true if collection is not empty
    #
    # ## Example
    #
    #   collection = Collection.new
    #   collection << Attribute::Base.new(:name, :string)
    #   collection << Attribute::Base.new(:age, :integer)
    #   collection.size  # => 2
    #   collection.exists?  # => true
    class Collection
      extend Forwardable

      def_delegators :@collection,
                     :<<,
                     :to_h, :map,
                     :each_with_object, :each,
                     :select, :reject, :size,
                     :find, :first,
                     :empty?

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
