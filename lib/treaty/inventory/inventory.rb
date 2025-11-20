# frozen_string_literal: true

module Treaty
  module Inventory
    # Represents a single inventory item that provides data to the treaty execution.
    #
    # An inventory item has a name and a source. The source can be:
    # - Symbol: A method name to call on the controller (e.g., :load_posts)
    # - Proc/Lambda: A callable object (e.g., -> { Post.all })
    # - Direct value: Any other value to pass directly (e.g., "text", 42)
    #
    # ## Usage
    #
    # ```ruby
    # # In controller
    # treaty :index do
    #   provide :posts, from: :load_posts
    #   provide :meta, from: -> { { count: 10 } }
    #   provide :title, from: "Welcome"
    # end
    # ```
    class Inventory
      attr_reader :name, :source

      def initialize(name:, source:)
        validate_name!(name)
        validate_source!(source)

        @name = name
        @source = source
      end

      # Evaluates the inventory source with the given controller context
      #
      # @param controller_context [Object] The controller instance to call methods on
      # @return [Object] The resolved value
      def evaluate(controller_context)
        case source
        when Symbol
          controller_context.send(source)
        when Proc
          source.call
        else
          source
        end
      end

      private

      def validate_name!(name)
        return if name.is_a?(Symbol) && !name.to_s.empty?

        raise Treaty::Exceptions::Inventory,
              I18n.t("treaty.inventory.invalid_name", name: name.inspect)
      end

      def validate_source!(source)
        # Source must be Symbol, Proc, or any other direct value
        # We don't allow nil as it's likely a mistake
        return unless source.nil?

        raise Treaty::Exceptions::Inventory,
              I18n.t("treaty.inventory.source_required")
      end
    end
  end
end
