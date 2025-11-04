# frozen_string_literal: true

module Treaty
  class Result
    attr_reader :data, :status

    def initialize(data:, status:)
      @data = data
      @status = status
    end

    def inspect
      "#<#{self.class.name} #{draw_result}>"
    end

    private

    def draw_result
      "@data=#{@data.inspect}, @status=#{@status.inspect}"
    end
  end
end
