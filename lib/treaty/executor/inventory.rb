# frozen_string_literal: true

module Treaty
  module Executor
    # Inventory wrapper that provides method-based access to inventory items.
    #
    # ## Purpose
    #
    # Wraps a hash of inventory data and allows accessing items through method calls
    # instead of hash key access. This provides a more intuitive API for services.
    #
    # ## Usage
    #
    # ```ruby
    # inventory = Treaty::Executor::Inventory.new({ posts: [Post.all], current_user: user })
    #
    # # Access via method calls
    # inventory.posts          # => [Post.all]
    # inventory.current_user   # => user
    #
    # # Raises exception for missing items
    # inventory.missing_item   # => Treaty::Exceptions::Inventory
    #
    # # Convert back to hash
    # inventory.to_h           # => { posts: [...], current_user: user }
    # ```
    #
    # ## Method Access
    #
    # The class uses `method_missing` to provide dynamic method access to inventory items.
    # Method names are converted to symbols and looked up in the internal data hash.
    #
    # ## Error Handling
    #
    # If an inventory item is not found, raises `Treaty::Exceptions::Inventory` with
    # an I18n-translated error message.
    class Inventory
      # Creates a new inventory instance
      #
      # @param data [Hash] Hash of inventory items (symbol keys => values)
      def initialize(data = {})
        @data = data.freeze
      end

      # Provides method-based access to inventory items
      #
      # @param method_name [Symbol] The inventory item name
      # @param args [Array] Arguments (not used, for compatibility)
      # @return [Object] The inventory item value
      # @raise [Treaty::Exceptions::Inventory] If item not found
      def method_missing(method_name, *_args)
        return @data.fetch(method_name) if @data.key?(method_name)

        raise Treaty::Exceptions::Inventory,
              I18n.t(
                "treaty.executor.inventory.item_not_found",
                name: method_name,
                available: @data.keys.join(", ")
              )
      end

      # Checks if inventory responds to a method
      #
      # @param method_name [Symbol] The method name to check
      # @param include_private [Boolean] Whether to include private methods
      # @return [Boolean] True if inventory has the item
      def respond_to_missing?(method_name, include_private = false)
        @data.key?(method_name) || super
      end

      # Converts inventory back to hash
      #
      # @return [Hash] The internal data hash
      def to_h
        @data
      end

      # Returns string representation
      #
      # @return [String] Inventory description
      def inspect
        "#<Treaty::Executor::Inventory items=#{@data.keys.inspect}>"
      end
    end
  end
end
