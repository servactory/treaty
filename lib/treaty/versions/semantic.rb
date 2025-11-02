# frozen_string_literal: true

module Treaty
  module Versions
    class Semantic
      def initialize(version)
        version =
          if version.is_a?(Array)
            version.join(".")
          # elsif version.is_a?(Integer)
          #   version.to_s
          else
            version # rubocop:disable Style/RedundantSelfAssignmentBranch
          end

        @version = Gem::Version.new(version)
      end
    end
  end
end
