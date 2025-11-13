# frozen_string_literal: true

module Treaty
  module Info
    module Entity
      module DSL
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def info
            builder = Builder.build(
              collection_of_attributes:
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
