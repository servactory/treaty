# frozen_string_literal: true

module Treaty
  module Attribute
    module Validation
      class Base
        def self.validate!(...)
          new(...).validate!
        end

        def initialize(version_factory:)
          @version_factory = version_factory
        end

        def validate!
          # TODO: It is necessary to implement a translation system (I18n).
          raise Treaty::Exceptions::Validation,
                "Subclass must implement the validate! method"
        end

        private

        def adapter_strategy?
          @version_factory.strategy_instance.adapter?
        end
      end
    end
  end
end
