# frozen_string_literal: true

module Treaty
  module Versions
    module DSL
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        private

        def version(version, &block)
          @version_factory ||= Factory.new(version)

          @version_factory.instance_eval(&block)
        end
      end
    end
  end
end
