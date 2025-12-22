# frozen_string_literal: true

module Treaty
  module Action
    module Response
      class Factory
        attr_reader :status

        def initialize(status)
          @status = status
        end

        def use_entity(entity_class)
          validate_entity_class!(entity_class)
          @entity_class = entity_class
        end

        def collection_of_attributes
          return Treaty::Entity::Attribute::Collection.new if @entity_class.nil?

          @entity_class.collection_of_attributes
        end

        def method_missing(type, *helpers, **options, &block)
          @entity_class ||= Class.new(Entity)

          @entity_class.public_send(type, *helpers, **options, &block)
        end

        def respond_to_missing?(name, *)
          super
        end

        private

        def validate_entity_class!(entity_class)
          return if entity_class.is_a?(Class) && entity_class < Treaty::Entity::Base

          raise Treaty::Exceptions::Validation,
                I18n.t(
                  "treaty.response.factory.invalid_entity_class",
                  type: entity_class.class,
                  value: entity_class
                )
        end
      end
    end
  end
end
