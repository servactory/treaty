# frozen_string_literal: true

module Treaty
  module Info
    module Entity
      module DSL
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          # Returns info about entity attributes with optional preset applied
          #
          # @param preset [Hash, nil] Preset options to apply to non-explicit attribute options
          # @return [Result] Info result wrapper
          def info(preset: nil)
            builder = Builder.build(
              collection_of_attributes:,
              entity_class: self,
              preset:
            )

            Result.new(builder)
          end

          # API: Treaty Web
          def treaty?
            true
          end
        end
      end
    end
  end
end
