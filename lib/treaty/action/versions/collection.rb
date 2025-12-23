# frozen_string_literal: true

module Treaty
  module Action
    module Versions
      # Collection wrapper for sets of version factories.
      #
      # ## Purpose
      #
      # Provides a unified interface for working with collections of version factories.
      # Uses Ruby Set internally for uniqueness but exposes Array-like interface.
      #
      # ## Usage
      #
      # Used internally by:
      # - Versions::DSL (to store version factories)
      # - Versions::Resolver (to find matching version)
      # - Info::Builder (to build version information)
      #
      # ## Methods
      #
      # Delegates common collection methods to internal Set:
      # - `<<` - Add version factory
      # - `map` - Iteration with transformation
      # - `find` - Access by condition
      #
      # ## Example
      #
      #   collection = Collection.new
      #   collection << Factory.new(version: 1, default: true)
      #   collection << Factory.new(version: 2, default: false)
      #   collection.find { |f| f.default_result }  # => Factory(v1)
      class Collection
        extend Forwardable

        def_delegators :@collection, :<<, :map, :find

        # Creates a new collection instance
        #
        # @param collection [Set] Initial collection (default: empty Set)
        def initialize(collection = Set.new)
          @collection = collection
        end
      end
    end
  end
end
