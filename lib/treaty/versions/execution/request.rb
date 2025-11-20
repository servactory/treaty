# frozen_string_literal: true

module Treaty
  module Versions
    module Execution
      class Request # rubocop:disable Metrics/ClassLength
        def self.execute!(...)
          new(...).execute!
        end

        def initialize(version_factory:, validated_params:, inventory: nil, context: nil)
          @inventory = inventory
          @context = context
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
              raise Treaty::Exceptions::Execution,
                    I18n.t("treaty.execution.executor_empty")
            end

            constant_name = normalize_constant_name(executor)

            begin
              constant_name.constantize
            rescue NameError
              raise Treaty::Exceptions::Execution,
                    I18n.t("treaty.execution.executor_not_found", class_name: constant_name)
            end
          else
            raise Treaty::Exceptions::Execution,
                  I18n.t("treaty.execution.executor_invalid_type", type: executor.class)
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

        # Evaluates inventory collection with context
        #
        # @return [Hash{Symbol => Object}] Hash of inventory name => resolved value
        def evaluated_inventory
          @evaluated_inventory ||= @inventory&.evaluate(@context) || {}
        end

        ########################################################################

        def execute_proc
          # For Proc executors, always pass inventory if collection exists
          if @inventory&.exists?
            executor.call(params: @validated_params, inventory: evaluated_inventory)
          else
            executor.call(params: @validated_params)
          end
        rescue StandardError => e
          raise Treaty::Exceptions::Execution,
                I18n.t("treaty.execution.proc_error", message: e.message)
        end

        def execute_servactory # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          # For Servactory services, only pass inventory if:
          # 1. Inventory collection exists AND
          # 2. Service has inventory input defined
          call_params =
            if @inventory&.exists? && service_accepts_inventory?
              { params: @validated_params, inventory: evaluated_inventory }
            else
              { params: @validated_params }
            end

          executor.call!(**call_params)
        rescue Servactory::Exceptions::Input => e
          raise Treaty::Exceptions::Execution,
                I18n.t("treaty.execution.servactory_input_error", message: e.message)
        rescue Servactory::Exceptions::Internal => e
          raise Treaty::Exceptions::Execution,
                I18n.t("treaty.execution.servactory_internal_error", message: e.message)
        rescue Servactory::Exceptions::Output => e
          raise Treaty::Exceptions::Execution,
                I18n.t("treaty.execution.servactory_output_error", message: e.message)
        rescue Servactory::Exceptions::Failure => e
          raise Treaty::Exceptions::Execution,
                I18n.t("treaty.execution.servactory_failure_error", message: e.message)
        end

        def execute_regular_class # rubocop:disable Metrics/MethodLength
          method_name = @version_factory.executor.method

          unless executor.respond_to?(method_name)
            raise Treaty::Exceptions::Execution,
                  I18n.t(
                    "treaty.execution.method_not_found",
                    method: method_name,
                    class_name: executor
                  )
          end

          # For regular classes, pass inventory if collection exists
          call_params =
            if @inventory&.exists?
              { params: @validated_params, inventory: evaluated_inventory }
            else
              { params: @validated_params }
            end

          executor.public_send(method_name, **call_params)
        rescue StandardError => e
          raise Treaty::Exceptions::Execution,
                I18n.t("treaty.execution.regular_service_error", message: e.message)
        end

        ########################################################################

        # Checks if Servactory service accepts inventory input
        #
        # @return [Boolean] True if service has inventory input defined
        def service_accepts_inventory?
          return false unless executor.respond_to?(:service_info)

          service_info = executor.service_info
          return false unless service_info.respond_to?(:inputs)

          service_info.inputs.collection_of_inputs.any? { |input| input.name == :inventory }
        end

        ########################################################################
        ########################################################################
        ########################################################################

        def raise_executor_missing_error!
          raise Treaty::Exceptions::Execution,
                I18n.t(
                  "treaty.execution.executor_missing",
                  version: @version_factory.version
                )
        end

        def servactory_service?
          executor.respond_to?(:servactory?) &&
            executor.servactory?
        end
      end
    end
  end
end
