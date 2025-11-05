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

      def resolve! # rubocop:disable Metrics/MethodLength
        factory =
          if current_version_blank?
            # Если версия не была передана, ищем дефолтную версию
            default_version_factory.tap do |default_factory|
              raise_current_version_not_found! if default_factory.nil?
            end
          else
            # Если версия передана, ищем её в коллекции
            version_factory.tap do |found_factory|
              raise_version_not_found! if found_factory.nil?
            end
          end

        raise_version_deprecated! if factory.deprecated_result

        factory
      end

      private

      def current_version
        @current_version ||=
          Treaty::Engine.config.treaty.version.call(@controller)
      end

      def current_version_blank?
        current_version.nil? || current_version.to_s.strip.empty?
      end

      def version_factory
        @version_factory ||=
          @collection_of_versions.find do |factory|
            factory.version.version == current_version
          end
      end

      def default_version_factory
        @default_version_factory ||=
          @collection_of_versions.find(&:default?)
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

      def raise_version_deprecated!
        # TODO: It is necessary to implement a translation system (I18n).
        raise Treaty::Exceptions::Deprecated,
              "Version #{current_version} is deprecated and cannot be used"
      end
    end
  end
end
