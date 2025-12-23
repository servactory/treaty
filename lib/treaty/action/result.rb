# frozen_string_literal: true

module Treaty
  module Action
    # Value object returned from treaty execution.
    #
    # ## Purpose
    #
    # Encapsulates the result of a treaty call, containing validated
    # response data, HTTP status code, and resolved version. This is
    # the primary return type from `Treaty.call!`.
    #
    # ## Usage
    #
    # Created by:
    # - Versions::Workspace (at the end of treaty execution)
    #
    # Consumed by:
    # - Controller::DSL (to render JSON response)
    # - Test assertions (to verify treaty behavior)
    #
    # ## Attributes
    #
    # | Attribute | Description |
    # |-----------|-------------|
    # | `data` | Validated and transformed response hash |
    # | `status` | HTTP status code from response definition |
    # | `version` | Resolved Gem::Version object |
    #
    # ## Example
    #
    #   result = Posts::CreateTreaty.call!(
    #     version: "1",
    #     params: { post: { title: "Hello" } }
    #   )
    #
    #   result.data    # => { post: { id: "abc", title: "Hello" } }
    #   result.status  # => 201
    #   result.version # => Gem::Version.new("1")
    #
    #   # In controller:
    #   render json: result.data, status: result.status
    class Result
      # @return [Hash] Validated response data
      attr_reader :data

      # @return [Integer] HTTP status code
      attr_reader :status

      # @return [Gem::Version] Resolved API version
      attr_reader :version

      # Creates a new result instance
      #
      # @param data [Hash] Validated response data
      # @param status [Integer] HTTP status code
      # @param version [Gem::Version] Resolved version
      def initialize(data:, status:, version:)
        @data = data
        @status = status
        @version = version
      end

      # Returns human-readable representation for debugging
      #
      # @return [String] Inspection string with all attributes
      def inspect
        "#<#{self.class.name} #{draw_result}>"
      end

      private

      # Formats attributes for inspect output
      #
      # @return [String] Formatted attribute string
      def draw_result
        "@data=#{@data.inspect}, @status=#{@status.inspect}, @version=#{@version.inspect}"
      end
    end
  end
end
