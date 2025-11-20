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

        # rubocop:disable Metrics/MethodLength
        def treaty(action_name, &block)
          define_method(action_name) do
            # Build inventory collection if block is provided
            inventory_collection =
              if block
                factory = Treaty::Inventory::Factory.new(action_name)
                factory.instance_eval(&block)
                factory.collection
              else
                Treaty::Inventory::Collection.new
              end

            # Call treaty with inventory collection
            treaty = treaty_class.call!(
              inventory: inventory_collection,
              controller_context: self,
              version: treaty_version,
              params:
            )

            render json: treaty.data, status: treaty.status
          end
        end
        # rubocop:enable Metrics/MethodLength
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
