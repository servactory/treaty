# frozen_string_literal: true

module Treaty
  module Action
    module Versions
      # Resolves version factory based on specified or default version.
      #
      # ## Purpose
      #
      # Finds the appropriate version factory from the collection based on:
      # - Specified version (from request header or parameter)
      # - Default version (if no version specified)
      #
      # Also enforces deprecation by raising error for deprecated versions.
      #
      # ## Usage
      #
      # Called internally by:
      # - Versions::Workspace (at the start of treaty execution)
      #
      # ## Resolution Logic
      #
      # 1. If version specified → find matching factory or raise VersionNotFound
      # 2. If no version → use default factory or raise SpecifiedVersionNotFound
      # 3. If resolved factory is deprecated → raise Deprecated
      #
      # ## Error Types
      #
      # | Error | Condition |
      # |-------|-----------|
      # | VersionNotFound | Specified version doesn't exist |
      # | SpecifiedVersionNotFound | No version specified and no default |
      # | Deprecated | Resolved version is marked deprecated |
      #
      # ## Example
      #
      #   # Find specific version:
      #   factory = Resolver.resolve!(
      #     specified_version: "2",
      #     collection_of_versions: collection
      #   )
      #
      #   # Use default version:
      #   factory = Resolver.resolve!(
      #     specified_version: nil,
      #     collection_of_versions: collection
      #   )
      class Resolver
        # Resolves version factory (class method shortcut)
        #
        # @param specified_version [String, nil] Requested version or nil for default
        # @param collection_of_versions [Treaty::Action::Versions::Collection] Available versions
        # @return [Treaty::Action::Versions::Factory] Resolved version factory
        # @raise [Treaty::Exceptions::VersionNotFound] If version doesn't exist
        # @raise [Treaty::Exceptions::SpecifiedVersionNotFound] If no default available
        # @raise [Treaty::Exceptions::Deprecated] If version is deprecated
        def self.resolve!(...)
          new(...).resolve!
        end

        # Creates a new resolver instance
        #
        # @param specified_version [String, nil] Requested version
        # @param collection_of_versions [Treaty::Action::Versions::Collection] Available versions
        def initialize(specified_version:, collection_of_versions:)
          @specified_version = specified_version
          @collection_of_versions = collection_of_versions
        end

        # Resolves and returns the appropriate version factory
        #
        # @return [Treaty::Action::Versions::Factory] Resolved version factory
        # @raise [Treaty::Exceptions::VersionNotFound] If version doesn't exist
        # @raise [Treaty::Exceptions::SpecifiedVersionNotFound] If no default available
        # @raise [Treaty::Exceptions::Deprecated] If version is deprecated
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

        # Finds factory matching specified version
        #
        # @return [Factory, nil] Matching factory or nil
        def version_factory
          @version_factory ||=
            @collection_of_versions.find do |factory|
              factory.version.version == @specified_version
            end
        end

        # Finds default version factory
        #
        # @return [Factory, nil] Default factory or nil
        def default_version_factory
          @default_version_factory ||=
            @collection_of_versions.find(&:default_result)
        end

        # Checks if specified version is blank
        #
        # @return [Boolean] True if version is nil or empty string
        def specified_version_blank?
          @specified_version.to_s.strip.empty?
        end

        ##########################################################################

        # Raises error when no version specified and no default exists
        #
        # @raise [Treaty::Exceptions::SpecifiedVersionNotFound]
        def raise_specified_version_not_found!
          raise Treaty::Exceptions::SpecifiedVersionNotFound,
                I18n.t("treaty.versioning.resolver.specified_version_required")
        end

        # Raises error when specified version doesn't exist
        #
        # @raise [Treaty::Exceptions::VersionNotFound]
        def raise_version_not_found!
          raise Treaty::Exceptions::VersionNotFound,
                I18n.t(
                  "treaty.versioning.resolver.version_not_found",
                  version: @specified_version
                )
        end

        # Raises error when resolved version is deprecated
        #
        # @raise [Treaty::Exceptions::Deprecated]
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
end
