# frozen_string_literal: true

module Treaty
  module Controllers
    module DSL
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        private

        def treaty(_action_name)
          # TODO
        end
      end
    end
  end
end
