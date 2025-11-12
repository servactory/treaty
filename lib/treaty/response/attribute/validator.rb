# frozen_string_literal: true

module Treaty
  module Response
    module Attribute
      class Validator < Treaty::Attribute::Validation::Base
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
          return @response_data unless response_attributes_exist?

          # For adapter strategy:
          Validation::Orchestrator.validate!(
            version_factory: @version_factory,
            data: @response_data
          )
        end

        def response_attributes_exist?
          return false if @version_factory.response_factory&.collection_of_attributes&.empty?

          @version_factory.response_factory.collection_of_attributes.exists?
        end
      end
    end
  end
end
