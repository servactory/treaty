# frozen_string_literal: true

module Treaty
  class Engine < ::Rails::Engine
    isolate_namespace Treaty

    config.treaty = Treaty::Configuration.new

    def self.configure
      yield(config.treaty) if block_given?
    end

    initializer "treaty.validate_configuration" do
      config.after_initialize do
        unless config.treaty.valid?
          errors = config.treaty.errors.full_messages
          raise "Invalid Treaty configuration: #{errors.join(', ')}"
        end
      end
    end
  end
end
