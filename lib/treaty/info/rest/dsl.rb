# frozen_string_literal: true

module Treaty
  module Info
    module Rest
      module DSL
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def info
            builder = Builder.build(
              collection_of_versions:
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
