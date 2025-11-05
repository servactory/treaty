# frozen_string_literal: true

module Treaty
  module Versions
    module DSL
      def self.included(base)
        base.extend(ClassMethods)
        base.include(Workspace)
      end

      module ClassMethods
        private

        def version(version, default: false, &block)
          @version_factory = Factory.new(version, default:)

          @version_factory.instance_eval(&block)

          collection_of_versions << @version_factory

          @version_factory = nil
        end

        def collection_of_versions
          @collection_of_versions ||= Collection.new
        end
      end
    end
  end
end
