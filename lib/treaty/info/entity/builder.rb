# frozen_string_literal: true

module Treaty
  module Info
    module Entity
      class Builder
        attr_reader :attributes

        def self.build(...)
          new.build(...)
        end

        def build(collection_of_attributes:)
          build_all(
            attributes: collection_of_attributes
          )

          self
        end

        private

        def build_all(attributes:)
          @attributes = build_versions_with(attributes)
        end

        ##########################################################################

        def build_versions_with(collection, current_level = 0)
          collection.to_h do |attribute|
            [
              attribute.name,
              {
                type: attribute.type,
                options: attribute.options,
                attributes: build_nested_attributes(attribute, current_level)
              }
            ]
          end
        end

        def build_nested_attributes(attribute, current_level)
          return {} unless attribute.nested?

          build_versions_with(attribute.collection_of_attributes, current_level + 1)
        end
      end
    end
  end
end
