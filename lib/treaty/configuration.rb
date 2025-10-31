# frozen_string_literal: true

module Treaty
  class Configuration
    include ::ActiveModel::Validations

    attr_accessor :version

    def initialize
      @version = ->(context) { context }
    end
  end
end
