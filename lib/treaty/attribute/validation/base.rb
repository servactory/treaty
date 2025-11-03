# frozen_string_literal: true

module Treaty
  module Attribute
    module Validation
      class Base
        attr_reader :current_version,
                    :collection_of_versions

        def self.validate!(...)
          new(...).validate!
        end

        def initialize(current_version:, collection_of_versions:)
          @current_version = current_version
          @collection_of_versions = collection_of_versions
        end

        def validate!
          # TODO: It is necessary to implement a translation system (I18n).
          raise Treaty::Exceptions::Validation,
                "Subclass must implement the validate! method"
        end

        private

        def version_factory
          @version_factory ||= find_version_factory
        end

        def find_version_factory
          return nil if current_version.nil?

          collection_of_versions.find do |factory|
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

        def adapter_strategy?
          version_factory.strategy_instance.adapter?
        end
      end
    end
  end
end
