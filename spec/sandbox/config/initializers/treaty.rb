# frozen_string_literal: true

Treaty::Engine.configure do |config|
  config.version = lambda do |context|
    accept = context.request.headers["Accept"]
    return if accept.blank?

    match = accept.match(%r{application/vnd\.myapp\.v(\d+)})
    return if match.blank?

    match[1].to_i
  end
end
