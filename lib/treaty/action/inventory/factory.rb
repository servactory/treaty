# frozen_string_literal: true

module Treaty
  module Action
    module Inventory
      class Factory
        attr_reader :collection

        def initialize(action_name)
          @action_name = action_name
          @collection = Collection.new
        end

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

        def respond_to_missing?(method_name, *)
          method_name == :provide || super
        end
      end
    end
  end
end
