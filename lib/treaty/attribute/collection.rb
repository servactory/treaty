# frozen_string_literal: true

require "forwardable"

module Treaty
  module Attribute
    class Collection
      extend Forwardable

      def_delegators :@collection, :<<, :to_h, :empty?

      def initialize(collection = Set.new)
        @collection = collection
      end

      def exists?
        !empty?
      end
    end
  end
end
