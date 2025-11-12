# frozen_string_literal: true

module Treaty
  module Request
    module Attribute
      class Validator < Treaty::Attribute::Validation::Base
        def self.validate!(...)
          new(...).validate!
        end

        def initialize(params:, version_factory:)
          super(version_factory:)

          @params = params
        end

        def validate!
          validate_request_attributes!
        end

        private

        def request_data
          @request_data ||= begin
            @params.to_unsafe_h
          rescue NoMethodError
            @params
          end
        end

        def validate_request_attributes!
          return request_data unless adapter_strategy?
          return request_data unless request_attributes_exist?

          # For adapter strategy:
          Validation::Orchestrator.validate!(
            version_factory: @version_factory,
            data: request_data
          )
        end

        def request_attributes_exist?
          return false if @version_factory.request_factory&.collection_of_attributes&.empty?

          @version_factory.request_factory.collection_of_attributes.exists?
        end
      end
    end
  end
end
