# frozen_string_literal: true

module Treaty
  module Action
    module Versions
      module Execution
        # Executes the configured service/proc with validated parameters.
        #
        # ## Purpose
        #
        # Handles the actual execution of the delegated service, supporting
        # multiple executor types: Class, String path, and Proc/Lambda.
        # Provides special handling for Servactory services.
        #
        # ## Usage
        #
        # Called by:
        # - Versions::Workspace (after request validation)
        #
        # ## Executor Types
        #
        # | Type | Example | Resolution |
        # |------|---------|------------|
        # | Class | `Posts::CreateService` | Direct call |
        # | String | `"posts/create_service"` | Constantized then called |
        # | Proc | `->(params:) { ... }` | Direct call |
        #
        # ## Servactory Integration
        #
        # Detects Servactory services via `servactory?` class method.
        # Catches Servactory-specific exceptions and wraps them in
        # `Treaty::Exceptions::Execution`.
        #
        # ## Execution Flow
        #
        # 1. Resolve executor (constantize string if needed)
        # 2. Build call parameters (params + optional inventory)
        # 3. Execute via appropriate method:
        #    - Proc: `executor.call(**params)`
        #    - Servactory: `executor.call!(**params)`
        #    - Regular: `executor.public_send(method, **params)`
        # 4. Extract data from result (handles `.data` accessor)
        #
        # ## Example
        #
        #   result = Execution::Request.execute!(
        #     version_factory: factory,
        #     validated_params: { post: { title: "Hello" } },
        #     inventory: inventory_collection,
        #     context: controller
        #   )
        class Request # rubocop:disable Metrics/ClassLength
          # Executes service with validated parameters (class method shortcut)
          #
          # @param version_factory [Factory] Version configuration
          # @param validated_params [Hash] Validated request parameters
          # @param inventory [Inventory::Collection, nil] Optional inventory
          # @param context [Object, nil] Controller context for inventory
          # @return [Hash] Service execution result
          # @raise [Treaty::Exceptions::Execution] If execution fails
          def self.execute!(...)
            new(...).execute!
          end

          # Creates a new execution request instance
          #
          # @param version_factory [Factory] Version with executor configuration
          # @param validated_params [Hash] Validated request parameters
          # @param inventory [Inventory::Collection, nil] Optional inventory
          # @param context [Object, nil] Controller context for inventory evaluation
          def initialize(version_factory:, validated_params:, inventory: nil, context: nil)
            @inventory = inventory
            @context = context
            @version_factory = version_factory
            @validated_params = validated_params
          end

          # Executes the service and returns result
          #
          # @return [Hash] Execution result data
          # @raise [Treaty::Exceptions::Execution] If executor missing or fails
          def execute!
            raise_executor_missing_error! if @version_factory.executor.nil?

            extract_data_from_result
          end

          private

          # Extracts data from execution result
          #
          # Handles different result types:
          # - Proc results returned directly
          # - Objects with `.data` accessor unwrapped
          # - Other results returned directly
          #
          # @return [Object] Extracted result data
          def extract_data_from_result
            return execution_result if executor.is_a?(Proc)
            return execution_result.data if execution_result.respond_to?(:data)

            execution_result
          end

          ########################################################################

          # Executes and caches the service result
          #
          # @return [Object] Raw execution result
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

          # Returns resolved executor (cached)
          #
          # @return [Class, Proc] Resolved executor
          def executor
            @executor ||= resolve_executor(@version_factory.executor.executor)
          end

          ########################################################################

          # Resolves executor from various input types
          #
          # @param executor [Class, String, Symbol, Proc] Executor reference
          # @return [Class, Proc] Resolved executor
          # @raise [Treaty::Exceptions::Execution] If resolution fails
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

          # Normalizes string/symbol to constant name
          #
          # Handles path-style strings like "posts/create_service"
          # converting to "Posts::CreateService".
          #
          # @param name [String, Symbol] Name to normalize
          # @return [String] Constant name
          def normalize_constant_name(name)
            string = name.to_s

            return string if string.include?("::")
            return string.split("/").map(&:camelize).join("::") if string.include?("/")

            string
          end

          ########################################################################
          ########################################################################
          ########################################################################

          # Creates inventory executor for lazy evaluation
          #
          # @return [Treaty::Action::Executor::Inventory] Inventory executor
          def evaluated_inventory
            @evaluated_inventory ||= Treaty::Action::Executor::Inventory.new(@inventory, @context)
          end

          ########################################################################

          # Executes Proc executor
          #
          # @return [Object] Proc result
          # @raise [Treaty::Exceptions::Execution] If proc raises error
          def execute_proc
            executor.call(**build_call_params)
          rescue StandardError => e
            raise Treaty::Exceptions::Execution,
                  I18n.t("treaty.execution.proc_error", message: e.message)
          end

          # Executes Servactory service
          #
          # Uses `call!` method and catches Servactory-specific exceptions.
          #
          # @return [Object] Service result
          # @raise [Treaty::Exceptions::Execution] If service raises error
          def execute_servactory # rubocop:disable Metrics/MethodLength
            executor.call!(**build_call_params)
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

          # Executes regular class with configured method
          #
          # @return [Object] Method result
          # @raise [Treaty::Exceptions::Execution] If method missing or raises error
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

            executor.public_send(method_name, **build_call_params)
          rescue StandardError => e
            raise Treaty::Exceptions::Execution,
                  I18n.t("treaty.execution.regular_service_error", message: e.message)
          end

          ########################################################################
          ########################################################################
          ########################################################################

          # Builds parameters hash for service call
          #
          # Includes validated params and optionally inventory if defined.
          #
          # @return [Hash] Call parameters
          def build_call_params
            if @inventory&.exists?
              { params: @validated_params, inventory: evaluated_inventory }
            else
              { params: @validated_params }
            end
          end

          # Raises error when executor not configured
          #
          # @raise [Treaty::Exceptions::Execution]
          def raise_executor_missing_error!
            raise Treaty::Exceptions::Execution,
                  I18n.t(
                    "treaty.execution.executor_missing",
                    version: @version_factory.version
                  )
          end

          # Checks if executor is a Servactory service
          #
          # @return [Boolean] True if executor responds to servactory?
          def servactory_service?
            executor.respond_to?(:servactory?) &&
              executor.servactory?
          end
        end
      end
    end
  end
end
