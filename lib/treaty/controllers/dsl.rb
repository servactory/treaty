# frozen_string_literal: true

module Treaty
  module Controllers
    module DSL
      def self.included(base)
        base.extend(ClassMethods)
        base.include(InstanceMethods)
      end

      module ClassMethods
        private

        def treaty(action_name) # rubocop:disable Metrics/MethodLength
          define_method(action_name) do
            _treaty = treaty_class.call!(controller: self, params:)

            # TODO
            # render json: treaty.data, status: treaty.status

            render json: {
              user: {
                id: SecureRandom.uuid,
                first_name: "John",
                middle_name: nil,
                last_name: "Doe"
              }
            }
          end
        end
      end

      module InstanceMethods
        def treaty_class
          treaty_class_name.constantize
        rescue NameError
          raise Treaty::Exceptions::ClassName, treaty_class_name
        end

        def treaty_class_name
          # TODO: Need to move `Treaty` to configuration.
          self.class.name.sub(/Controller$/, "::#{action_name.to_s.classify}Treaty")
        end
      end
    end
  end
end
