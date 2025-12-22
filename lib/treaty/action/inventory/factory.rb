# frozen_string_literal: true

module Treaty
  module Action
    module Inventory
      # Factory for building inventory collections from controller DSL.
      #
      # ## Purpose
      #
      # Provides the `provide` DSL method used in controller treaty blocks
      # to define inventory items. Inventory allows controllers to pass
      # data (current_user, loaded records, etc.) to services.
      #
      # ## Usage
      #
      # Created by:
      # - Controller::DSL (when treaty block is evaluated)
      #
      # ## DSL Method
      #
      # The only supported method is `provide`:
      #
      #   treaty :index do
      #     provide :current_user                    # Shorthand: same name as method
      #     provide :posts, from: :load_posts        # Symbol source
      #     provide :meta, from: -> { build_meta }   # Proc source
      #     provide :limit, from: 10                 # Direct value
      #   end
      #
      # ## Source Types
      #
      # | Type | Description | Evaluation |
      # |------|-------------|------------|
      # | Symbol | Controller method name | `context.send(source)` |
      # | Proc | Lambda/block | `context.instance_exec(&source)` |
      # | Other | Direct value | Returned as-is |
      #
      # ## Example
      #
      #   factory = Factory.new(:index)
      #   factory.provide :current_user
      #   factory.provide :posts, from: :load_posts
      #   factory.collection  # => Collection with 2 items
      class Factory
        # @return [Collection] Collection of inventory items
        attr_reader :collection

        # Creates a new factory instance
        #
        # @param action_name [Symbol] Controller action name (for error messages)
        def initialize(action_name)
          @action_name = action_name
          @collection = Collection.new
        end

        # Handles DSL method calls (only `provide` is supported)
        #
        # Creates an Inventory item and adds it to the collection.
        # Validates that only `provide` method is called and name is a Symbol.
        #
        # @param method_name [Symbol] Method name (must be :provide)
        # @param args [Array] Arguments (first must be inventory name as Symbol)
        # @param options [Hash] Options (:from for source)
        # @raise [Treaty::Exceptions::Inventory] If method is not `provide`
        # @raise [Treaty::Exceptions::Inventory] If name is not a Symbol
        # @return [Collection] Updated collection
        def method_missing(method_name, *args, **options, &_block) # rubocop:disable Metrics/MethodLength
          unless method_name == :provide
            raise Treaty::Exceptions::Inventory,
                  I18n.t(
                    "treaty.inventory.unknown_method",
                    method: method_name,
                    action: @action_name
                  )
          end

          inventory_name = args.first

          unless inventory_name.is_a?(Symbol)
            raise Treaty::Exceptions::Inventory,
                  I18n.t(
                    "treaty.inventory.name_must_be_symbol",
                    name: inventory_name.inspect
                  )
          end

          source = if options.key?(:from)
                     options.fetch(:from)
                   else
                     inventory_name
                   end

          @collection << Inventory.new(name: inventory_name, source:)

          @collection
        end

        # Checks if method should be handled by method_missing
        #
        # @param method_name [Symbol] Method name
        # @return [Boolean] True only for :provide
        def respond_to_missing?(method_name, *)
          method_name == :provide || super
        end
      end
    end
  end
end
