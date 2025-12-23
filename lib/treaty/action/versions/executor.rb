# frozen_string_literal: true

module Treaty
  module Action
    module Versions
      # Value object holding executor reference and method name.
      #
      # ## Purpose
      #
      # Stores the service class/proc and method name configured via
      # `delegate_to` in version definitions. Separates executor
      # configuration from execution logic.
      #
      # ## Usage
      #
      # Created by:
      # - Versions::Factory (when `delegate_to` is called)
      #
      # Consumed by:
      # - Versions::Execution::Request (to execute the service)
      #
      # ## Executor Types
      #
      # The `executor` attribute can hold:
      # - Class reference: `Posts::CreateService`
      # - String path: `"posts/create_service"`
      # - Proc/Lambda: `->(params:) { ... }`
      #
      # ## Method Attribute
      #
      # The `method` attribute specifies which method to call:
      # - Default: `:call`
      # - Custom: specified via hash syntax `delegate_to Service => :perform`
      #
      # ## Example
      #
      #   # In version definition:
      #   delegate_to Posts::CreateService           # method defaults to :call
      #   delegate_to Posts::CreateService => :call! # explicit method
      #
      #   # Creates:
      #   Executor.new(Posts::CreateService, :call)
      class Executor
        # @return [Class, String, Proc] Service class, path string, or proc
        attr_reader :executor

        # @return [Symbol] Method name to call on executor
        attr_reader :method

        # Creates a new executor value object
        #
        # @param executor [Class, String, Proc] Service reference
        # @param method [Symbol] Method to invoke (default: :call)
        def initialize(executor, method)
          @executor = executor
          @method = method
        end
      end
    end
  end
end
