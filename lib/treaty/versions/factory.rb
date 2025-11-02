# frozen_string_literal: true

module Treaty
  module Versions
    class Factory
      attr_reader :version,
                  :summary_text,
                  :strategy_code,
                  :deprecated_result

      def initialize(version)
        @version = Semantic.new(version)
        @summary_text = nil
        @strategy_code = :adapter
        @deprecated_result = false
      end

      def summary(text)
        @summary_text = text
      end

      def strategy(name)
        @strategy_code = name
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

      def request(_domain, &_block)
        # @request_factory ||= Factory.new(domain)
        #
        # @request_factory.instance_eval(&block)
      end

      def response(_domain, _status, &_block)
        # @response_factory ||= Factory.new(domain)
        #
        # @response_factory.instance_eval(&block)
      end

      def delegate_to(service_class)
        service_class
      end

      # def method_missing(name, *helpers, **options)
      # end

      # def respond_to_missing?(name, *)
      #   super
      # end
    end
  end
end
