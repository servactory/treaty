# frozen_string_literal: true

module Treaty
  module Attribute
    module Validation
      class Request < Base
        attr_reader :controller

        def self.validate!(controller:, current_version:, collection_of_versions:)
          new(
            controller:,
            current_version:,
            collection_of_versions:
          ).validate!
        end

        def initialize(controller:, current_version:, collection_of_versions:)
          super(current_version:, collection_of_versions:)

          @controller = controller
        end

        def validate!
          raise_current_version_not_found! if current_version.nil?

          raise_version_not_found! if version_factory.nil?

          validate_request_attributes!
        end

        private

        def request_data
          @request_data ||= begin
            controller.params.to_unsafe_h
          rescue NoMethodError
            controller.params
          end
        end

        def validate_request_attributes!
          return unless adapter_strategy?

          return unless request_attributes_exist?

          Orchestrator::Request.validate!(
            version_factory:,
            data: request_data
          )
        end

        def request_attributes_exist?
          return false if version_factory.request_factory&.collection_of_scopes&.empty?

          version_factory.request_factory.collection_of_scopes.exists?
        end
      end
    end
  end
end
