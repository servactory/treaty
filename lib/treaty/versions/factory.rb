# frozen_string_literal: true

module Treaty
  module Versions
    class Factory
      attr_reader :version,
                  :summary_text,
                  :strategy_instance,
                  :deprecated_result,
                  :executor,
                  :request_factory,
                  :response_factory

      def initialize(version)
        @version = Semantic.new(version)
        @summary_text = nil
        @strategy_instance = Strategy.new(Strategy::ADAPTER) # without .validate!
        @deprecated_result = false
        @executor = nil
      end

      def summary(text)
        @summary_text = text
      end

      def strategy(code)
        @strategy_instance = Strategy.new(code).validate!
      end

      def deprecated(condition = nil)
        result =
          if condition.is_a?(Proc)
            condition.call
          elsif condition.is_a?(TrueClass) || condition.is_a?(FalseClass)
            condition
          else
            yield
          end

        @deprecated_result = result
      end

      def request(&block)
        @request_factory ||= Request::Factory.new

        @request_factory.instance_eval(&block) if block_given?
      end

      def response(status, &block)
        @response_factory ||= Response::Factory.new(status)

        @response_factory.instance_eval(&block) if block_given?
      end

      def delegate_to(executor)
        @executor = executor
      end

      ##########################################################################

      def method_missing(name, *, &_block)
        # TODO: It is necessary to implement a translation system (I18n).
        raise Treaty::Exceptions::MethodName, "Unknown method: #{name}"
      end

      def respond_to_missing?(name, *)
        super
      end
    end
  end
end
