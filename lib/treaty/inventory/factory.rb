# frozen_string_literal: true

module Treaty
  module Inventory
    # Factory for building inventory collections via DSL.
    #
    # ## Purpose
    #
    # Provides the `provide` DSL method for defining inventory items in controller blocks.
    # Captures calls like `provide :posts, from: :load_posts` and builds a collection.
    #
    # ## Usage
    #
    # Used internally by Controller::DSL when processing treaty blocks:
    #
    # ```ruby
    # treaty :index do
    #   provide :posts, from: :load_posts       # Explicit source
    #   provide :meta, from: -> { { count: 10 } } # Lambda source
    #   provide :current_user                   # Shorthand: uses :current_user as source
    # end
    # ```
    #
    # ## Valid Sources
    #
    # - Symbol: Method name to call on controller (e.g., `:load_posts`)
    # - Proc/Lambda: Callable object (e.g., `-> { Post.all }`)
    # - Direct value: String, number, or any other value (e.g., `"Welcome"`)
    # - Omitted: Uses inventory name as source (e.g., `provide :posts` → `from: :posts`)
    #
    # ## Invalid Sources
    #
    # - Direct method calls without symbol/proc (e.g., `from: load_posts`)
    # - Explicit nil values (e.g., `from: nil`)
    class Factory
      attr_reader :collection

      def initialize(action_name)
        @action_name = action_name
        @collection = Collection.new
      end

      # Handles the `provide` DSL method via method_missing
      #
      # @param method_name [Symbol] Should be :provide
      # @param args [Array] First argument is the inventory name
      # @param options [Hash] Optional :from key with source (defaults to inventory name)
      # @return [Collection] The collection being built
      # @raise [Treaty::Exceptions::Inventory] For invalid method or missing parameters
      def method_missing(method_name, *args, **options, &_block) # rubocop:disable Metrics/MethodLength
        # Only handle 'provide' method
        unless method_name == :provide
          raise Treaty::Exceptions::Inventory,
                I18n.t(
                  "treaty.inventory.unknown_method",
                  method: method_name,
                  action: @action_name
                )
        end

        # Extract inventory name
        inventory_name = args.first

        unless inventory_name.is_a?(Symbol)
          raise Treaty::Exceptions::Inventory,
                I18n.t(
                  "treaty.inventory.name_must_be_symbol",
                  name: inventory_name.inspect
                )
        end

        # Extract source from options (default to inventory name if not provided)
        source = if options.key?(:from)
                   options.fetch(:from)
                 else
                   inventory_name
                 end

        # Create and add inventory item to collection
        @collection << Inventory.new(name: inventory_name, source:)

        # Return collection for potential chaining
        @collection
      end

      def respond_to_missing?(method_name, *)
        method_name == :provide || super
      end
    end
  end
end
