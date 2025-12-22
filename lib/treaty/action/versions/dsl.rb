# frozen_string_literal: true

module Treaty
  module Action
    module Versions
      # DSL module for defining API versions in treaty classes.
      #
      # ## Purpose
      #
      # Provides the `version` class method for defining API versions.
      # Each version can have its own request/response schema, executor,
      # summary, and deprecation status.
      #
      # ## Usage
      #
      # Included in:
      # - Treaty::Action::Base (as core DSL functionality)
      #
      # ## DSL Methods
      #
      # When included, provides:
      # - `version` - Define a new API version with configuration block
      # - `collection_of_versions` - Access all defined versions
      #
      # ## Version Definition
      #
      #   class Posts::CreateTreaty < ApplicationTreaty
      #     version 1, default: true do
      #       summary "Initial version"
      #
      #       request do
      #         object :post do
      #           string :title, :required
      #         end
      #       end
      #
      #       response 201 do
      #         object :post do
      #           string :id
      #         end
      #       end
      #
      #       delegate_to Posts::CreateService
      #     end
      #
      #     version 2 do
      #       summary "Added tags"
      #       deprecated { ENV["V2_DEPRECATED"] == "true" }
      #       # ...
      #     end
      #   end
      #
      # ## Validation
      #
      # Validates that only one version is marked as default.
      # Raises `VersionMultipleDefaults` if multiple defaults detected.
      module DSL
        # Hook called when module is included
        #
        # @param base [Class] The class including this module
        def self.included(base)
          base.extend(ClassMethods)
          base.include(Workspace)
        end

        # Class methods added to including class
        module ClassMethods
          private

          # Defines a new API version
          #
          # Creates a version factory, evaluates the configuration block,
          # validates the configuration, and adds to collection.
          #
          # @param version [Integer, String, Array] Version identifier
          # @param default [Boolean] Whether this is the default version
          # @param block [Proc] Configuration block (request, response, delegate_to, etc.)
          # @raise [Treaty::Exceptions::VersionMultipleDefaults] If multiple defaults
          # @return [void]
          def version(version, default: false, &block)
            @version_factory = Factory.new(version:, default:)

            @version_factory.instance_eval(&block)
            @version_factory.validate_after_block!

            validate_multiple_defaults! if @version_factory.default_result == true

            collection_of_versions << @version_factory

            @version_factory = nil
          end

          # Returns collection of all defined versions
          #
          # @return [Collection] Collection of version factories
          def collection_of_versions
            @collection_of_versions ||= Collection.new
          end

          # Validates that only one version is marked as default
          #
          # @raise [Treaty::Exceptions::VersionMultipleDefaults] If multiple defaults
          # @return [void]
          def validate_multiple_defaults!
            existing_defaults = collection_of_versions.map(&:default_result).count(true)

            return if existing_defaults.zero?

            raise Treaty::Exceptions::VersionMultipleDefaults,
                  I18n.t("treaty.versioning.factory.multiple_defaults")
          end
        end
      end
    end
  end
end
