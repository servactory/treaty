# frozen_string_literal: true

module Treaty
  module Action
    class Result
      attr_reader :data, :status, :version

      def initialize(data:, status:, version:)
        @data = data
        @status = status
        @version = version
      end

      def inspect
        "#<#{self.class.name} #{draw_result}>"
      end

      private

      def draw_result
        "@data=#{@data.inspect}, @status=#{@status.inspect}, @version=#{@version.inspect}"
      end
    end
  end
end
