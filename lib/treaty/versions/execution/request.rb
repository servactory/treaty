# frozen_string_literal: true

module Treaty
  module Versions
    module Execution
      class Request
        def self.execute!(...)
          new(...).execute!
        end

        def initialize(version_factory:, validated_params:)
          @version_factory = version_factory
          @validated_params = validated_params
        end

        def execute!
          raise_executor_missing_error! if @version_factory.executor.nil?

          extract_data_from_result
        end

        private

        def extract_data_from_result
          return execution_result if executor.is_a?(Proc)
          return execution_result.data if execution_result.respond_to?(:data)

          execution_result
        end

        ########################################################################

        def execution_result
          @execution_result ||=
            if executor.is_a?(Proc)
              execute_proc
            elsif servactory_service?
              execute_servactory
            else
              execute_regular_class
            end
        end

        ########################################################################

        def executor
          @executor ||= resolve_executor(@version_factory.executor.executor)
        end

        ########################################################################

        def resolve_executor(executor) # rubocop:disable Metrics/MethodLength
          return executor if executor.is_a?(Proc) || executor.is_a?(Class)

          if executor.is_a?(String) || executor.is_a?(Symbol)
            string_executor = executor.to_s

            if string_executor.empty?
              # TODO: It is necessary to implement a translation system (I18n).
              raise Treaty::Exceptions::Execution,
                    "Executor cannot be an empty string"
            end

            constant_name = normalize_constant_name(executor)

            begin
              constant_name.constantize
            rescue NameError
              # TODO: It is necessary to implement a translation system (I18n).
              raise Treaty::Exceptions::Execution,
                    "Executor class `#{constant_name}` not found"
            end
          else
            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Execution,
                  "Invalid executor type: #{executor.class}. " \
                  "Expected Proc, Class, String, or Symbol"
          end
        end

        ########################################################################

        def normalize_constant_name(name)
          string = name.to_s

          return string if string.include?("::")
          return string.split("/").map(&:camelize).join("::") if string.include?("/")

          string
        end

        ########################################################################
        ########################################################################
        ########################################################################

        def execute_proc
          executor.call(params: @validated_params)
        rescue StandardError => e
          # TODO: It is necessary to implement a translation system (I18n).
          raise Treaty::Exceptions::Execution, e.message
        end

        def execute_servactory
          executor.call!(params: @validated_params)
        rescue ApplicationService::Exceptions::Input => e
          # TODO: It is necessary to implement a translation system (I18n).
          raise Treaty::Exceptions::Execution, e.message
        rescue ApplicationService::Exceptions::Internal => e # rubocop:disable Lint/DuplicateBranch
          # TODO: It is necessary to implement a translation system (I18n).
          raise Treaty::Exceptions::Execution, e.message
        rescue ApplicationService::Exceptions::Output => e # rubocop:disable Lint/DuplicateBranch
          # TODO: It is necessary to implement a translation system (I18n).
          raise Treaty::Exceptions::Execution, e.message
        rescue ApplicationService::Exceptions::Failure => e # rubocop:disable Lint/DuplicateBranch
          # TODO: It is necessary to implement a translation system (I18n).
          raise Treaty::Exceptions::Execution, e.message
        end

        def execute_regular_class
          method_name = @version_factory.executor.method

          unless executor.respond_to?(method_name)
            # TODO: It is necessary to implement a translation system (I18n).
            raise Treaty::Exceptions::Execution,
                  "Method '#{method_name}' not found in class '#{executor}'"
          end

          executor.public_send(method_name, params: @validated_params)
        rescue StandardError => e
          # TODO: It is necessary to implement a translation system (I18n).
          raise Treaty::Exceptions::Execution, e.message
        end

        ########################################################################
        ########################################################################
        ########################################################################

        def raise_executor_missing_error!
          # TODO: It is necessary to implement a translation system (I18n).
          raise Treaty::Exceptions::Execution,
                "Executor is not defined for version #{@version_factory.version}"
        end

        def servactory_service?
          executor.respond_to?(:servactory?) &&
            executor.servactory?
        end
      end
    end
  end
end
