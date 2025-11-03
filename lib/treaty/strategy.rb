# frozen_string_literal: true

module Treaty
  class Strategy
    DIRECT = :direct
    ADAPTER = :adapter

    LIST = [DIRECT, ADAPTER].freeze

    attr_reader :code

    def initialize(code)
      @code = code
    end

    def validate!
      return self if LIST.include?(@code)

      # TODO: It is necessary to implement a translation system (I18n).
      raise Treaty::Exceptions::Strategy, "Unknown strategy: #{@code}"
    end

    def direct?
      @code == DIRECT
    end

    def adapter?
      @code == ADAPTER
    end
  end
end
