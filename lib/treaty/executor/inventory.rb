# frozen_string_literal: true

module Treaty
  module Executor
    # Inventory wrapper that provides method-based access to inventory items.
    #
    # ## Purpose
    #
    # Wraps inventory collection and controller context, providing lazy evaluation
    # of inventory items through method calls. This encapsulates all inventory logic
    # within the class and provides a clean API for services.
    #
    # ## Usage
    #
    # ```ruby
    # # Created internally by Treaty
    # inventory = Treaty::Executor::Inventory.new(inventory_collection, controller_context)
    #
    # # Access via method calls - evaluates lazily
    # inventory.posts          # => Calls controller method or evaluates proc
    # inventory.current_user   # => Returns evaluated value
    #
    # # Raises exception for missing items
    # inventory.missing_item   # => Treaty::Exceptions::Inventory
    #
    # # Convert to hash - evaluates all items
    # inventory.to_h           # => { posts: [...], current_user: ... }
    # ```
    #
    # ## Architecture
    #
    # The class encapsulates:
    # - Inventory collection (from controller's treaty block)
    # - Controller context (for method calls and proc evaluation)
    # - Lazy evaluation logic (items evaluated on access)
    #
    # ## Error Handling
    #
    # If an inventory item is not found, raises `Treaty::Exceptions::Inventory` with
    # an I18n-translated error message listing available items.
    class Inventory
      # Creates a new inventory instance
      #
      # @param inventory [Treaty::Inventory::Collection] Collection of inventory items
      # @param context [Object] Controller instance for evaluation
      def initialize(inventory, context)
        @inventory = inventory
        @context = context
        @evaluated_cache = {}
      end

      # Provides method-based access to inventory items with lazy evaluation
      #
      # @param method_name [Symbol] The inventory item name
      # @param _args [Array] Arguments (not used, for compatibility)
      # @return [Object] The evaluated inventory item value
      # @raise [Treaty::Exceptions::Inventory] If item not found
      def method_missing(method_name, *_args)
        # Check cache first
        return @evaluated_cache[method_name] if @evaluated_cache.key?(method_name)

        # Find inventory item
        item = find_inventory_item(method_name)

        # Evaluate and cache
        @evaluated_cache[method_name] = item.evaluate(@context)
      end

      # Checks if inventory responds to a method
      #
      # @param method_name [Symbol] The method name to check
      # @param include_private [Boolean] Whether to include private methods
      # @return [Boolean] True if inventory has the item
      def respond_to_missing?(method_name, include_private = false)
        return true if @inventory.nil?

        @inventory.names.include?(method_name) || super
      end

      # Converts inventory to hash, evaluating all items
      #
      # @return [Hash] Hash of all evaluated inventory items
      def to_h
        return {} if @inventory.nil?

        @inventory.evaluate(@context)
      end

      # Returns string representation
      #
      # @return [String] Inventory description
      def inspect
        items = @inventory&.names || []
        "#<Treaty::Executor::Inventory items=#{items.inspect}>"
      end

      private

      # Finds inventory item by name
      #
      # @param name [Symbol] Inventory item name
      # @return [Treaty::Inventory::Inventory] The inventory item
      # @raise [Treaty::Exceptions::Inventory] If not found or inventory is nil
      def find_inventory_item(name)
        # Use find method for cleaner search
        item = @inventory&.find { |item| item.name == name }

        return item if item

        # Item not found - list available items
        available = @inventory&.names || []

        raise Treaty::Exceptions::Inventory,
              I18n.t(
                "treaty.executor.inventory.item_not_found",
                name:,
                available: available.join(", ")
              )
      end
    end
  end
end
