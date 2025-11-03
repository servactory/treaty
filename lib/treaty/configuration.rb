# frozen_string_literal: true

module Treaty
  class Configuration
    include ::ActiveModel::Validations

    attr_accessor :version

    attr_reader :attribute_nesting_level

    def initialize
      @version = ->(context) { context }

      @attribute_nesting_level = 5
    end
  end
end
