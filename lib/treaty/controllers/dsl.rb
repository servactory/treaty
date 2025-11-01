# frozen_string_literal: true

module Treaty
  module Controllers
    module DSL
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        private

        def treaty(action_name)
          define_method(action_name) do
            # TODO
            render json: :ok
          end
        end
      end
    end
  end
end
