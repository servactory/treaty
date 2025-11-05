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
        # TODO: It is necessary to implement a translation system (I18n).
        raise Treaty::Exceptions::Validation,
              "Current version is required for validation"
      end

      def raise_version_not_found!
        # TODO: It is necessary to implement a translation system (I18n).
        raise Treaty::Exceptions::Validation,
              "Version #{current_version} not found in treaty definition"
      end

      def raise_version_deprecated!
        # TODO: It is necessary to implement a translation system (I18n).
        raise Treaty::Exceptions::Deprecated,
              "Version #{current_version} is deprecated and cannot be used"
      end
    end
  end
end
