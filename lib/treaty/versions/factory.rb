# frozen_string_literal: true

module Treaty
  module Versions
    class Factory
      attr_reader :version,
                  :default_result,
                  :summary_text,
                  :strategy_instance,
                  :deprecated_result,
                  :executor,
                  :request_factory,
                  :response_factory

      def initialize(version:, default:)
        @version = Semantic.new(version)
        @default_result = default.is_a?(Proc) ? default.call : default
        @summary_text = nil
        @strategy_instance = Strategy.new(Strategy::ADAPTER) # without .validate!
        @deprecated_result = false
        @executor = nil

        validate!
      end

      def validate!
        validate_default_option!
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

      def request(entity_class = nil, &block)
        @request_factory ||= Request::Factory.new

        if entity_class.present?
          # Delegate validation to Request::Factory
          @request_factory.use_entity(entity_class)
        elsif block_given?
          # For blocks, use instance_eval to allow multiple request blocks to be merged
          @request_factory.instance_eval(&block)
        end
      end

      def response(status, entity_class = nil, &block)
        @response_factory ||= Response::Factory.new(status)

        if entity_class.present?
          # Delegate validation to Response::Factory
          @response_factory.use_entity(entity_class)
        elsif block_given?
          # For blocks, use instance_eval to allow multiple response blocks to be merged
          @response_factory.instance_eval(&block)
        end
      end

      def delegate_to(executor, method = :call)
        @executor = Executor.new(executor, method)
      end

      ##########################################################################

      private

      def validate_default_option!
        if @default_result.is_a?(TrueClass) || @default_result.is_a?(FalseClass) || @default_result.is_a?(Proc)
          return @default_result
        end

        raise Treaty::Exceptions::Validation,
              I18n.t("treaty.versioning.factory.invalid_default_option", type: @default_result.class)
      end

      ##########################################################################

      def method_missing(name, *, &_block)
        raise Treaty::Exceptions::MethodName,
              I18n.t("treaty.versioning.factory.unknown_method", method: name)
      end

      def respond_to_missing?(name, *)
        super
      end
    end
  end
end
