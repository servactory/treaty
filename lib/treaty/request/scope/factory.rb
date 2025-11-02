# frozen_string_literal: true

module Treaty
  module Request
    module Scope
      class Factory
        attr_reader :name

        def initialize(name)
          @name = name
        end

        def method_missing(name, *, &_block)
          # TODO: It needs to be implemented.
          puts "Unknown request scope block method: #{name}"
        end

        def respond_to_missing?(name, *)
          super
        end
      end
    end
  end
end
