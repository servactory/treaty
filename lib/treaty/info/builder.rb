# frozen_string_literal: true

module Treaty
  module Info
    class Builder
      attr_reader :versions

      def self.build(...)
        new.build(...)
      end

      def build(collection_of_versions:)
        build_all(
          versions: collection_of_versions
        )

        self
      end

      private

      def build_all(versions:)
        build_versions_with(
          collection: versions
        )
      end

      def build_versions_with(collection:)
        @versions = collection.map do |version|
          version = version.version.version
          {
            version: version.version,
            segments: version.segments
          }
        end
      end
    end
  end
end
