# frozen_string_literal: true

module Treaty
  module Controller
    module DSL
      def self.included(base)
        base.extend(ClassMethods)
        base.include(InstanceMethods)
      end

      module ClassMethods
        private

        def treaty(action_name)
          define_method(action_name) do
            treaty = treaty_class.call!(version: treaty_version, params:)

            render json: treaty.data, status: treaty.status
          end
        end
      end

      module InstanceMethods
        def treaty_class
          treaty_class_name.constantize
        rescue NameError
          raise Treaty::Exceptions::ClassName,
                I18n.t(
                  "treaty.controller.treaty_class_not_found",
                  class_name: treaty_class_name
                )
        end

        def treaty_class_name
          # TODO: Need to move `Treaty` to configuration.
          self.class.name.sub(/Controller$/, "::#{action_name.to_s.classify}Treaty")
        end

        def treaty_version
          Treaty::Engine.config.treaty.version.call(self)
        end
      end
    end
  end
end
