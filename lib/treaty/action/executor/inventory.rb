# frozen_string_literal: true

module Treaty
  module Action
    module Executor
      # Lazy-evaluating proxy for accessing inventory items.
      #
      # ## Purpose
      #
      # Provides lazy evaluation and caching of inventory items defined in controllers.
      # Acts as a proxy that evaluates inventory items only when accessed, avoiding
      # unnecessary computation for unused items.
      #
      # ## Usage
      #
      # Created internally by:
      # - Versions::Execution::Request (when executing treaty versions)
      #
      # Passed to:
      # - Service classes (as `inventory` parameter)
      # - Proc executors (as `inventory:` keyword argument)
      #
      # ## Access Patterns
      #
      # Method-based access (lazy, cached):
      #   inventory.current_user  # Evaluates and caches on first call
      #   inventory.current_user  # Returns cached value
      #
      # Hash-based access (evaluates all items):
      #   inventory.to_h  # => { current_user: <User>, posts: [...] }
      #
      # ## Caching
      #
      # Once an item is evaluated via method access, the result is cached
      # in `@evaluated_cache`. Subsequent calls return the cached value
      # without re-evaluation.
      #
      # ## Example
      #
      #   # In controller:
      #   treaty :index do
      #     provide :current_user
      #     provide :posts, from: :load_posts
      #   end
      #
      #   # In service:
      #   class Posts::IndexService
      #     def call(inventory:, params:)
      #       user = inventory.current_user  # Lazy evaluation
      #       posts = inventory.posts        # Lazy evaluation
      #       # ...
      #     end
      #   end
      class Inventory
        # Creates a new inventory executor instance
        #
        # @param inventory [Treaty::Action::Inventory::Collection, nil] Collection of inventory items
        # @param context [Object] Controller context for evaluating items (typically ActionController instance)
        def initialize(inventory, context)
          @inventory = inventory
          @context = context
          @evaluated_cache = {}
        end

        # Handles dynamic method calls to access inventory items
        #
        # Looks up the inventory item by method name, evaluates it with
        # the controller context, and caches the result.
        #
        # @param method_name [Symbol] Name of the inventory item to access
        # @return [Object] Evaluated value from the inventory item
        # @raise [Treaty::Exceptions::Inventory] If item with given name not found
        def method_missing(method_name, *_args)
          return @evaluated_cache[method_name] if @evaluated_cache.key?(method_name)

          item = find_inventory_item(method_name)

          @evaluated_cache[method_name] = item.evaluate(@context)
        end

        # Checks if method corresponds to an inventory item
        #
        # @param method_name [Symbol] Method name to check
        # @param include_private [Boolean] Whether to include private methods
        # @return [Boolean] True if inventory contains item with given name
        def respond_to_missing?(method_name, include_private = false)
          return false if @inventory.nil?

          @inventory.names.include?(method_name) || super
        end

        # Evaluates all inventory items and returns as hash
        #
        # Unlike method-based access, this evaluates ALL items at once.
        # Useful when you need all inventory data as a hash.
        #
        # @return [Hash{Symbol => Object}] Hash of all evaluated inventory values
        def to_h
          return {} if @inventory.nil?

          @inventory.evaluate(@context)
        end

        # Returns human-readable representation for debugging
        #
        # @return [String] Inspection string with available item names
        def inspect
          items = @inventory&.names || []
          "#<Treaty::Action::Executor::Inventory items=#{items.inspect}>"
        end

        private

        # Finds inventory item by name or raises error
        #
        # @param name [Symbol] Name of the inventory item
        # @return [Treaty::Action::Inventory::Inventory] Found inventory item
        # @raise [Treaty::Exceptions::Inventory] If item not found
        def find_inventory_item(name)
          item = @inventory&.find { |item| item.name == name }

          return item if item

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
end
