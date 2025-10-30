# frozen_string_literal: true

module Pactory
  class Engine < ::Rails::Engine
    isolate_namespace Pactory

    config.pactory = Pactory::Configuration.new

    def self.configure
      yield(config.pactory) if block_given?
    end

    initializer "pactory.validate_configuration" do
      config.after_initialize do
        unless config.pactory.valid?
          errors = config.pactory.errors.full_messages
          raise "Invalid Pactory configuration: #{errors.join(', ')}"
        end
      end
    end
  end
end
