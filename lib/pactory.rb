# frozen_string_literal: true

require "pactory/support/loader"

module Pactory
end

require "pactory/engine" if defined?(Rails::Engine)
