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

        def treaty(action_name) # rubocop:disable Metrics/MethodLength
          define_method(action_name) do # rubocop:disable Metrics/MethodLength
            _treaty = treaty_class.call!(controller: self, params:)

            # TODO: Need to apply the result of Treaty here.
            # render json: treaty.data, status: treaty.status

            render json: {
              post: {
                id: SecureRandom.uuid,
                title: "Understanding Kubernetes Pod Networking: A Deep Dive",
                summary:
                  "Explore how pods communicate in Kubernetes clusters and learn the fundamentals of CNI plugins, " \
                  "network policies, and service mesh integration.",
                description:
                  "This comprehensive guide breaks down the complex world of Kubernetes networking, " \
                  "explaining how containers within pods share network namespaces and " \
                  "how inter-pod communication works across nodes.",
                content: "..."
              }
            }
          end
        end
      end

      module InstanceMethods
        def treaty_class
          treaty_class_name.constantize
        rescue NameError
          # TODO: It is necessary to implement a translation system (I18n).
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
