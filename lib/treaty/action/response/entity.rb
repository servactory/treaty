# frozen_string_literal: true

module Treaty
  module Action
    module Response
      class Entity
        include Treaty::Entity::Attribute::DSL

        class << self
          private

          def create_attribute(name, type, *helpers, nesting_level:, **options, &block)
            Attribute::Attribute.new(
              name,
              type,
              *helpers,
              nesting_level:,
              **options,
              &block
            )
          end
        end
      end
    end
  end
end
