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
        raise_current_version_not_found! if current_version.nil?

        raise_version_not_found! if version_factory.nil?

        version_factory
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
    end
  end
end
