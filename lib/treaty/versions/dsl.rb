# frozen_string_literal: true

module Treaty
  module Versions
    module DSL
      def self.included(base)
        base.extend(ClassMethods)
        base.include(Workspace)
      end

      module ClassMethods
        private

        def version(version, default: false, &block)
          @version_factory = Factory.new(version:, default:)

          @version_factory.instance_eval(&block)
          @version_factory.validate_after_block!

          validate_multiple_defaults! if @version_factory.default_result == true

          collection_of_versions << @version_factory

          @version_factory = nil
        end

        def collection_of_versions
          @collection_of_versions ||= Collection.new
        end

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
