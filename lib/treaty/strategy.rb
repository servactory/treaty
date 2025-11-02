# frozen_string_literal: true

module Treaty
  class Strategy
    DIRECT = :direct
    ADAPTER = :adapter

    LIST = [DIRECT, ADAPTER].freeze

    attr_reader :code

    def initialize(code)
      @code = code

      return if LIST.include?(code)

      raise Treaty::Exceptions::Strategy,
            "Unknown strategy: #{code}"
    end

    def direct?
      @code == DIRECT
    end

    def adapter?
      @code == ADAPTER
    end
  end
end
