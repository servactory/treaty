# frozen_string_literal: true

module Treaty
  module Response
    class Collection
      extend Forwardable

      def_delegators :@collection, :<<

      def initialize(collection = Set.new)
        @collection = collection
      end
    end
  end
end
