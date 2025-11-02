# frozen_string_literal: true

module Treaty
  module Response
    class Factory
      def initialize(domain, status)
        @domain = domain
        @status = status
      end

      def method_missing(name, *, &_block)
        # TODO: It needs to be implemented.
        puts "Unknown response block method: #{name}"
      end

      def respond_to_missing?(name, *)
        super
      end
    end
  end
end
