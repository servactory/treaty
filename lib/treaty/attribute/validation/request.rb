# frozen_string_literal: true

module Treaty
  module Attribute
    module Validation
      class Request < Base
        def self.validate!(...)
          new(...).validate!
        end

        def initialize(controller:, version_factory:)
          super(version_factory:)

          @controller = controller
        end

        def validate!
          validate_request_attributes!
        end

        private

        def request_data
          @request_data ||= begin
            @controller.params.to_unsafe_h
          rescue NoMethodError
            @controller.params
          end
        end

        def validate_request_attributes!
          return unless adapter_strategy?
          return unless request_attributes_exist?

          Orchestrator::Request.validate!(
            version_factory: @version_factory,
            data: request_data
          )
        end

        def request_attributes_exist?
          return false if @version_factory.request_factory&.collection_of_scopes&.empty?

          @version_factory.request_factory.collection_of_scopes.exists?
        end
      end
    end
  end
end
