# frozen_string_literal: true

module Treaty
  class Entity
    module Processing
      # Processing workspace for Entity validation and transformation.
      # Contains specific logic: validate_and_transform!, build_orchestrator.
      #
      # Uses @incoming_arguments stored by Context::Workspace.
      #
      # Follows the Treaty::Versions::Workspace pattern (chaining via super).
      module Workspace
        private

        def call!(incoming_arguments:, preset: nil)
          super

          result = Entity::Result.new
          validated_data = validate_and_transform!
          result.data = validated_data
          result
        end

        def validate_and_transform!
          orchestrator = build_orchestrator
          orchestrator.validate!
        end

        def build_orchestrator
          entity_class = self.class
          current_preset = @preset

          orchestrator_class = Class.new(Attribute::Validation::Orchestrator::Base) do
            define_method(:collection_of_attributes) do
              entity_class.collection_of_attributes
            end
          end

          orchestrator_class.new(version_factory: nil, data: @incoming_arguments, preset: current_preset)
        end
      end
    end
  end
end
