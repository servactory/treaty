# frozen_string_literal: true

module Treaty
  module Versions
    class Resolver
      def self.resolve!(...)
        new(...).resolve!
      end

      def initialize(controller:, collection_of_versions:)
        @controller = controller
        @collection_of_versions = collection_of_versions
      end

      def resolve!
        determined_factory =
          if current_version_blank?
            default_version_factory || raise_current_version_not_found!
          else
            version_factory || raise_version_not_found!
          end

        raise_version_deprecated! if determined_factory.deprecated_result

        determined_factory
      end

      private

      def current_version
        @current_version ||=
          Treaty::Engine.config.treaty.version.call(@controller)
      end

      def version_factory
        @version_factory ||=
          @collection_of_versions.find do |factory|
            factory.version.version == current_version
          end
      end

      def default_version_factory
        @default_version_factory ||=
          @collection_of_versions.find(&:default_result)
      end

      def current_version_blank?
        current_version.to_s.strip.empty?
      end

      ##########################################################################

      def raise_current_version_not_found!
        raise Treaty::Exceptions::Validation,
              I18n.t("treaty.versioning.resolver.current_version_required")
      end

      def raise_version_not_found!
        raise Treaty::Exceptions::Validation,
              I18n.t("treaty.versioning.resolver.version_not_found", version: current_version)
      end

      def raise_version_deprecated!
        raise Treaty::Exceptions::Deprecated,
              I18n.t("treaty.versioning.resolver.version_deprecated", version: current_version)
      end
    end
  end
end
