# frozen_string_literal: true

module Treaty
  module Action
    module Versions
      # Semantic version wrapper using Gem::Version.
      #
      # ## Purpose
      #
      # Normalizes version inputs (Integer, String, Array) into a consistent
      # Gem::Version object. This enables proper version comparison and
      # semantic versioning support.
      #
      # ## Usage
      #
      # Created internally by:
      # - Versions::Factory (to store version number)
      #
      # Consumed by:
      # - Versions::Resolver (to match requested version)
      # - Info::Builder (to display version info)
      #
      # ## Version Formats
      #
      # Accepts multiple input formats:
      # - Integer: `1` → "1"
      # - String: `"1.0.0"` → "1.0.0"
      # - Array: `[1, 0, 0]` → "1.0.0"
      #
      # ## Underlying Implementation
      #
      # Uses Gem::Version internally which provides:
      # - Semantic version comparison (1.0.0 < 1.0.1 < 1.1.0 < 2.0.0)
      # - Proper handling of pre-release versions (1.0.0-alpha < 1.0.0)
      # - String normalization
      #
      # ## Example
      #
      #   Semantic.new(1).version           # => Gem::Version.new("1")
      #   Semantic.new("1.2.3").version     # => Gem::Version.new("1.2.3")
      #   Semantic.new([1, 2, 3]).version   # => Gem::Version.new("1.2.3")
      class Semantic
        # @return [Gem::Version] Normalized semantic version
        attr_reader :version

        # Creates a new semantic version wrapper
        #
        # @param version [Integer, String, Array] Version in any supported format
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
end
