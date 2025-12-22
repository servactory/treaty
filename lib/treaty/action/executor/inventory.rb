# frozen_string_literal: true

module Treaty
  module Action
    module Executor
      class Inventory
        def initialize(inventory, context)
          @inventory = inventory
          @context = context
          @evaluated_cache = {}
        end

        def method_missing(method_name, *_args)
          return @evaluated_cache[method_name] if @evaluated_cache.key?(method_name)

          item = find_inventory_item(method_name)

          @evaluated_cache[method_name] = item.evaluate(@context)
        end

        def respond_to_missing?(method_name, include_private = false)
          return false if @inventory.nil?

          @inventory.names.include?(method_name) || super
        end

        def to_h
          return {} if @inventory.nil?

          @inventory.evaluate(@context)
        end

        def inspect
          items = @inventory&.names || []
          "#<Treaty::Action::Executor::Inventory items=#{items.inspect}>"
        end

        private

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
