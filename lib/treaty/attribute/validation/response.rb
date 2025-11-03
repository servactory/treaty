# frozen_string_literal: true

# TODO: This is a prototype, this class is not used.
module Treaty
  module Attribute
    module Validation
      class Response < Base
        def self.validate!(version_factory:, response_data: {})
          new(
            version_factory:,
            response_data:
          ).validate!
        end

        def initialize(version_factory:, response_data: {})
          super(version_factory:)

          @response_data = response_data
        end

        def validate!
          validate_response_attributes!
        end

        private

        def validate_response_attributes!
          return unless adapter_strategy?
          return unless response_attributes_exist?

          Orchestrator::Response.validate!(
            version_factory: @version_factory,
            data: @response_data
          )
        end

        def response_attributes_exist?
          return false if @version_factory.response_factory&.collection_of_scopes&.empty?

          @version_factory.response_factory.collection_of_scopes.exists?
        end
      end
    end
  end
end
