# frozen_string_literal: true

module Treaty
  module Request
    class Factory
      def initialize(domain)
        @domain = domain
      end

      def method_missing(name, *, &_block)
        # TODO: It needs to be implemented.
        puts "Unknown request block method: #{name}"
      end

      def respond_to_missing?(name, *)
        super
      end
    end
  end
end
