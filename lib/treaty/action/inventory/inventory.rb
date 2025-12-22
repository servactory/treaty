# frozen_string_literal: true

module Treaty
  module Action
    module Inventory
      # Individual inventory item with lazy evaluation.
      #
      # ## Purpose
      #
      # Represents a single piece of data that can be passed from controller
      # to service. Stores the name and source, and can be evaluated against
      # a controller context when needed.
      #
      # ## Usage
      #
      # Created by:
      # - Inventory::Factory (when `provide` is called)
      #
      # Consumed by:
      # - Inventory::Collection (for bulk evaluation)
      # - Executor::Inventory (for lazy single-item evaluation)
      #
      # ## Source Types
      #
      # | Type | Example | Evaluation |
      # |------|---------|------------|
      # | Symbol | `:current_user` | Calls `context.send(:current_user)` |
      # | Proc | `-> { Time.current }` | Calls `context.instance_exec(&proc)` |
      # | Other | `10`, `"string"` | Returns value as-is |
      #
      # ## Lazy Evaluation
      #
      # The source is NOT evaluated at creation time. Evaluation happens
      # only when `evaluate(context)` is called, typically during treaty
      # execution when the service needs the value.
      #
      # ## Example
      #
      #   # Symbol source (method call)
      #   item = Inventory.new(name: :current_user, source: :current_user)
      #   item.evaluate(controller)  # => calls controller.current_user
      #
      #   # Proc source (block execution)
      #   item = Inventory.new(name: :meta, source: -> { { time: Time.current } })
      #   item.evaluate(controller)  # => executes block in controller context
      #
      #   # Direct value
      #   item = Inventory.new(name: :limit, source: 10)
      #   item.evaluate(controller)  # => 10
      class Inventory
        # @return [Symbol] Inventory item name
        attr_reader :name

        # @return [Symbol, Proc, Object] Source for evaluation
        attr_reader :source

        # Creates a new inventory item
        #
        # @param name [Symbol] Item name (must be non-empty Symbol)
        # @param source [Symbol, Proc, Object] Evaluation source
        # @raise [Treaty::Exceptions::Inventory] If name is invalid
        # @raise [Treaty::Exceptions::Inventory] If source is nil
        def initialize(name:, source:)
          validate_name!(name)
          validate_source!(source)

          @name = name
          @source = source
        end

        # Evaluates source against controller context
        #
        # Behavior depends on source type:
        # - Symbol: calls method on context
        # - Proc: executes in context scope
        # - Other: returns value directly
        #
        # @param context [Object] Controller instance
        # @return [Object] Evaluated value
        # @raise [Treaty::Exceptions::Inventory] If evaluation fails
        def evaluate(context) # rubocop:disable Metrics/MethodLength
          case source
          when Symbol
            evaluate_symbol(context)
          when Proc
            evaluate_proc(context)
          else
            source
          end
        rescue StandardError => e
          raise Treaty::Exceptions::Inventory,
                I18n.t(
                  "treaty.inventory.evaluation_error",
                  name: @name,
                  error: e.message
                )
        end

        private

        # Evaluates Symbol source by calling method on context
        #
        # @param context [Object] Controller instance
        # @return [Object] Method return value
        def evaluate_symbol(context)
          context.send(source)
        end

        # Evaluates Proc source in context scope
        #
        # Uses instance_exec so proc has access to controller
        # instance variables and private methods.
        #
        # @param context [Object] Controller instance
        # @return [Object] Proc return value
        def evaluate_proc(context)
          context.instance_exec(&source)
        end

        # Validates that name is a non-empty Symbol
        #
        # @param name [Object] Name to validate
        # @raise [Treaty::Exceptions::Inventory] If invalid
        # @return [void]
        def validate_name!(name)
          return if name.is_a?(Symbol) && !name.to_s.empty?

          raise Treaty::Exceptions::Inventory,
                I18n.t("treaty.inventory.invalid_name", name: name.inspect)
        end

        # Validates that source is not nil
        #
        # @param source [Object] Source to validate
        # @raise [Treaty::Exceptions::Inventory] If nil
        # @return [void]
        def validate_source!(source)
          return unless source.nil?

          raise Treaty::Exceptions::Inventory,
                I18n.t("treaty.inventory.source_required")
        end
      end
    end
  end
end
