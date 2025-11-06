# frozen_string_literal: true

module Treaty
  class Engine < ::Rails::Engine
    isolate_namespace Treaty

    config.treaty = Treaty::Configuration.new

    def self.configure
      yield(config.treaty) if block_given?
    end

    initializer "treaty.register_option_processors", before: :load_config_initializers do
      # Register all option processors (validators and modifiers)
      require "treaty/attribute/option/registry_initializer"
    end

    initializer "treaty.validate_configuration" do
      config.after_initialize do
        unless config.treaty.valid?
          errors = config.treaty.errors.full_messages
          raise "Invalid Treaty configuration: #{errors.join(', ')}"
        end
      end
    end

    initializer "treaty.controller_methods" do
      ActiveSupport.on_load(:action_controller_base) do
        include Treaty::Controller::DSL
      end

      ActiveSupport.on_load(:action_controller_api) do
        include Treaty::Controller::DSL
      end
    end
  end
end
