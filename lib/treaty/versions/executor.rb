# frozen_string_literal: true

module Treaty
  module Versions
    class Executor
      attr_reader :executor, :method

      def initialize(executor, method)
        @executor = executor
        @method = method
      end
    end
  end
end
