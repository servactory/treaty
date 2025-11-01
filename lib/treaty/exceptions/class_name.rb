# frozen_string_literal: true

module Treaty
  module Exceptions
    class ClassName < Base
      def initialize(class_name)
        super("Invalid class name: #{class_name}")
      end
    end
  end
end
