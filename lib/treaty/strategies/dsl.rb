# frozen_string_literal: true

module Treaty
  module Strategies
    module DSL
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        private

        def strategy(name)
          name
        end
      end
    end
  end
end
