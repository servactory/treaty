# frozen_string_literal: true

module Treaty
  module Request
    class Factory
      def scope(name, &block)
        @scope_factory = Scope::Factory.new(name)

        @scope_factory.instance_eval(&block) if block_given?

        collection_of_scopes << @scope_factory

        @scope_factory = nil
      end

      def collection_of_scopes
        @collection_of_scopes ||= Scope::Collection.new
      end

      ##########################################################################

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
