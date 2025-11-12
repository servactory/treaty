# frozen_string_literal: true

module Treaty
  module Response
    module Attribute
      module Validation
        class Orchestrator < Treaty::Attribute::Validation::Orchestrator::Base
          private

          def collection_of_attributes
            return Treaty::Attribute::Collection.new if version_factory.response_factory.nil?

            version_factory.response_factory.collection_of_attributes
          end
        end
      end
    end
  end
end
