# frozen_string_literal: true

module Treaty
  module Versions
    class Factory
      attr_reader :version,
                  :summary_text,
                  :strategy_instance,
                  :deprecated_result,
                  :executor

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

      def request(domain, &block)
        @request_factory = Request::Factory.new(domain)

        @request_factory.instance_eval(&block) if block_given?

        collection_of_requests << @request_factory

        @request_factory = nil
      end

      def response(domain, status, &block)
        @response_factory = Response::Factory.new(domain, status)

        @response_factory.instance_eval(&block) if block_given?

        collection_of_responses << @response_factory

        @response_factory = nil
      end

      def delegate_to(service_class)
        @executor = service_class
      end

      def collection_of_requests
        @collection_of_requests ||= Request::Collection.new
      end

      def collection_of_responses
        @collection_of_responses ||= Response::Collection.new
      end

      ##########################################################################

      def method_missing(name, *, &_block)
        raise Treaty::Exceptions::MethodName, "Unknown method: #{name}"
      end

      def respond_to_missing?(name, *)
        super
      end
    end
  end
end
