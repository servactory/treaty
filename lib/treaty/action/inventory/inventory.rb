# frozen_string_literal: true

module Treaty
  module Action
    module Inventory
      class Inventory
        attr_reader :name, :source

        def initialize(name:, source:)
          validate_name!(name)
          validate_source!(source)

          @name = name
          @source = source
        end

        def evaluate(context) # rubocop:disable Metrics/MethodLength
          case source
          when Symbol
            evaluate_symbol(context)
          when Proc
            evaluate_proc(context)
          else
            source
          end
        rescue StandardError => e
          raise Treaty::Exceptions::Inventory,
                I18n.t(
                  "treaty.inventory.evaluation_error",
                  name: @name,
                  error: e.message
                )
        end

        private

        def evaluate_symbol(context)
          context.send(source)
        end

        def evaluate_proc(context)
          context.instance_exec(&source)
        end

        def validate_name!(name)
          return if name.is_a?(Symbol) && !name.to_s.empty?

          raise Treaty::Exceptions::Inventory,
                I18n.t("treaty.inventory.invalid_name", name: name.inspect)
        end

        def validate_source!(source)
          return unless source.nil?

          raise Treaty::Exceptions::Inventory,
                I18n.t("treaty.inventory.source_required")
        end
      end
    end
  end
end
