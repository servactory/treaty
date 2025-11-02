# frozen_string_literal: true

module Treaty
  module Versions
    class Factory
      attr_reader :version,
                  :summary_text,
                  :strategy_code

      def initialize(version)
        @version = Semantic.new(version)
      end

      def summary(text)
        @summary_text = text
      end

      def strategy(name)
        @strategy_code = name
      end

      def deprecated(&_block) # rubocop:disable Naming/PredicateMethod
        false
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
