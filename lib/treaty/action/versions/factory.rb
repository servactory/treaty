# frozen_string_literal: true

module Treaty
  module Action
    module Versions
      # Factory for version configuration and DSL.
      #
      # ## Purpose
      #
      # Provides the DSL interface within `version` blocks. Captures all
      # version configuration: summary, deprecation, request schema,
      # response schema, and executor delegation.
      #
      # ## Usage
      #
      # Created by:
      # - Versions::DSL (when `version` is called)
      #
      # Consumed by:
      # - Versions::Resolver (to find matching version)
      # - Versions::Execution::Request (to execute the service)
      # - Request::Validator / Response::Validator (to get schemas)
      # - Info::Builder (to build version information)
      #
      # ## DSL Methods
      #
      # | Method | Purpose |
      # |--------|---------|
      # | `summary` | Set version description text |
      # | `deprecated` | Mark version as deprecated (bool or proc) |
      # | `request` | Define request schema (block or entity class) |
      # | `response` | Define response schema with status code |
      # | `delegate_to` | Set service class/proc to execute |
      #
      # ## Example
      #
      #   version 1, default: true do
      #     summary "Initial API version"
      #
      #     deprecated { ENV["V1_DEPRECATED"] == "true" }
      #
      #     request do
      #       object :post do
      #         string :title, :required
      #       end
      #     end
      #
      #     response 201 do
      #       object :post do
      #         string :id
      #       end
      #     end
      #
      #     delegate_to Posts::CreateService
      #   end
      #
      # ## Validation
      #
      # - `default` must be boolean or Proc
      # - Cannot be both default and deprecated
      class Factory
        # @return [Semantic] Semantic version wrapper
        attr_reader :version

        # @return [Boolean] Whether this is the default version
        attr_reader :default_result

        # @return [String, nil] Version summary/description
        attr_reader :summary_text

        # @return [Boolean] Whether version is deprecated
        attr_reader :deprecated_result

        # @return [Executor, nil] Executor configuration
        attr_reader :executor

        # @return [Request::Factory, nil] Request schema factory
        attr_reader :request_factory

        # @return [Response::Factory, nil] Response schema factory
        attr_reader :response_factory

        # Creates a new version factory
        #
        # @param version [Integer, String, Array] Version identifier
        # @param default [Boolean, Proc] Whether this is the default version
        def initialize(version:, default:)
          @version = Semantic.new(version)
          @default_result = default.is_a?(Proc) ? default.call : default
          @summary_text = nil
          @deprecated_result = false
          @executor = nil

          validate!
        end

        # Validates configuration on creation
        #
        # @return [void]
        def validate!
          validate_default_option!
        end

        # Validates configuration after block evaluation
        #
        # @raise [Treaty::Exceptions::VersionDefaultDeprecatedConflict]
        # @return [void]
        def validate_after_block!
          validate_default_deprecated_conflict!
        end

        # Sets version summary text
        #
        # @param text [String] Version description
        # @return [void]
        def summary(text)
          @summary_text = text
        end

        # Marks version as deprecated
        #
        # Accepts boolean, Proc, or block that evaluates to boolean.
        # Deprecated versions raise error when accessed.
        #
        # @param condition [Boolean, Proc, nil] Deprecation condition
        # @yield Block that returns boolean
        # @return [void]
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

        # Defines request schema
        #
        # Accepts either an Entity class or a block with attribute definitions.
        #
        # @param entity_class [Class, nil] Entity class for request schema
        # @yield Block with request attribute definitions
        # @return [void]
        def request(entity_class = nil, &block)
          @request_factory ||= Request::Factory.new

          if entity_class.present?
            @request_factory.use_entity(entity_class)
          elsif block_given?
            @request_factory.instance_eval(&block)
          end
        end

        # Defines response schema with HTTP status
        #
        # Accepts status code and either Entity class or block.
        #
        # @param status [Integer] HTTP status code (200, 201, 404, etc.)
        # @param entity_class [Class, nil] Entity class for response schema
        # @yield Block with response attribute definitions
        # @return [void]
        def response(status, entity_class = nil, &block)
          @response_factory ||= Response::Factory.new(status)

          if entity_class.present?
            @response_factory.use_entity(entity_class)
          elsif block_given?
            @response_factory.instance_eval(&block)
          end
        end

        # Configures service delegation
        #
        # Sets the executor (class, string, or proc) and method to call.
        #
        # @param executor [Class, String, Proc, Hash] Service reference
        # @param method [Symbol] Method to call (default: :call)
        # @return [void]
        #
        # @example Class reference
        #   delegate_to Posts::CreateService
        #
        # @example With custom method
        #   delegate_to Posts::CreateService => :call!
        #
        # @example String path
        #   delegate_to "posts/create_service"
        #
        # @example Lambda
        #   delegate_to ->(params:) { { id: SecureRandom.uuid } }
        def delegate_to(executor, method = :call)
          @executor = Executor.new(executor, method)
        end

        ##########################################################################

        private

        # Validates default option is boolean or Proc
        #
        # @raise [Treaty::Exceptions::Validation] If invalid type
        # @return [Boolean, Proc]
        def validate_default_option!
          if @default_result.is_a?(TrueClass) || @default_result.is_a?(FalseClass) || @default_result.is_a?(Proc)
            return @default_result
          end

          raise Treaty::Exceptions::Validation,
                I18n.t(
                  "treaty.versioning.factory.invalid_default_option",
                  type: @default_result.class
                )
        end

        # Validates version is not both default and deprecated
        #
        # @raise [Treaty::Exceptions::VersionDefaultDeprecatedConflict]
        # @return [void]
        def validate_default_deprecated_conflict!
          return unless @default_result == true
          return unless @deprecated_result == true

          raise Treaty::Exceptions::VersionDefaultDeprecatedConflict,
                I18n.t(
                  "treaty.versioning.factory.default_deprecated_conflict",
                  version: @version.version
                )
        end

        ##########################################################################

        # Catches unknown DSL methods with helpful error
        #
        # @raise [Treaty::Exceptions::MethodName]
        def method_missing(name, *, &_block)
          raise Treaty::Exceptions::MethodName,
                I18n.t("treaty.versioning.factory.unknown_method", method: name)
        end

        # Required for method_missing
        #
        # @return [Boolean]
        def respond_to_missing?(name, *)
          super
        end
      end
    end
  end
end
