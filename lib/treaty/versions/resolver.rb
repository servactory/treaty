# frozen_string_literal: true

module Treaty
  module Versions
    class Resolver
      def self.resolve!(...)
        new(...).resolve!
      end

      def initialize(specified_version:, collection_of_versions:)
        @specified_version = specified_version
        @collection_of_versions = collection_of_versions
      end

      def resolve!
        determined_factory =
          if specified_version_blank?
            default_version_factory || raise_specified_version_not_found!
          else
            version_factory || raise_version_not_found!
          end

        raise_version_deprecated! if determined_factory.deprecated_result

        determined_factory
      end

      private

      def version_factory
        @version_factory ||=
          @collection_of_versions.find do |factory|
            factory.version.version == @specified_version
          end
      end

      def default_version_factory
        @default_version_factory ||=
          @collection_of_versions.find(&:default_result)
      end

      def specified_version_blank?
        @specified_version.to_s.strip.empty?
      end

      ##########################################################################

      def raise_specified_version_not_found!
        raise Treaty::Exceptions::SpecifiedVersionNotFound,
              I18n.t("treaty.versioning.resolver.specified_version_required")
      end

      def raise_version_not_found!
        raise Treaty::Exceptions::VersionNotFound,
              I18n.t(
                "treaty.versioning.resolver.version_not_found",
                version: @specified_version
              )
      end

      def raise_version_deprecated!
        raise Treaty::Exceptions::Deprecated,
              I18n.t(
                "treaty.versioning.resolver.version_deprecated",
                version: @specified_version
              )
      end
    end
  end
end
