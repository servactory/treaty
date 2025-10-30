# frozen_string_literal: true

require "treaty/support/loader"

module Treaty
end

require "treaty/engine" if defined?(Rails::Engine)
