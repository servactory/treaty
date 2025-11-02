# frozen_string_literal: true

module Treaty
  module Info
    module DSL
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def info
          Result.new
        end

        # API: Treaty Web
        def treaty?
          true
        end
      end
    end
  end
end
