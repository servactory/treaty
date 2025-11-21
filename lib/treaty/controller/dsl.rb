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

        def treaty(action_name, &block) # rubocop:disable Metrics/MethodLength
          # Capture block in a local variable before using in define_method.
          # This is necessary because define_method creates a new closure,
          # and the block parameter might not be accessible without explicit capture.
          inventory_block = block

          define_method(action_name) do
            inventory_collection = treaty_build_inventory_for(action_name, inventory_block)

            treaty_result = treaty_class.call!(
              context: self,
              inventory: inventory_collection,
              version: treaty_version,
              params:
            )

            render json: treaty_result.data, status: treaty_result.status
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

        private

        def treaty_build_inventory_for(action_name, block)
          return nil unless block

          factory = Treaty::Inventory::Factory.new(action_name)
          factory.instance_eval(&block)
          factory.collection
        end
      end
    end
  end
end
