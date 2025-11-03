# frozen_string_literal: true

# TODO: This is a prototype, this class is not used.
module Treaty
  module Attribute
    module Validation
      class Response < Base
        attr_reader :response_data

        def self.validate!(current_version:, collection_of_versions:, response_data: {})
          new(
            current_version:,
            collection_of_versions:,
            response_data:
          ).validate!
        end

        def initialize(current_version:, collection_of_versions:, response_data: {})
          super(current_version:, collection_of_versions:)

          @response_data = response_data
        end

        def validate!
          raise_current_version_not_found! unless current_version

          raise_version_not_found! unless version_factory

          validate_response_attributes!
        end

        private

        def validate_response_attributes!
          return unless adapter_strategy?

          return unless response_attributes_exist?

          Orchestrator::Response.validate!(
            version_factory:,
            data: response_data
          )
        end

        def response_attributes_exist?
          return false unless version_factory.response_factory&.collection_of_scopes

          version_factory.response_factory.collection_of_scopes.exists?
        end
      end
    end
  end
end
