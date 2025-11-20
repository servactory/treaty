# frozen_string_literal: true

module Treaty
  module Inventory
    class Factory
      def initialize(action_name)
        @action_name = action_name
      end

      def method_missing(name, *, &_block)
        # Temporary solution
        puts "Inventory: #{name}"

        # TODO:
        # raise Treaty::Exceptions::*,
        #       I18n.t("treaty.*", ...)
      end

      def respond_to_missing?(name, *)
        super
      end
    end
  end
end
