# frozen_string_literal: true

Treaty::Engine.configure do |config|
  config.version = lambda do |controller|
    vendor_version_header_regex =
      %r{\Aapplication/vnd\.(?<vendor>[a-z0-9.\-_!^]+?)(?:-v(?<version>[0-9*.]+))?(?:\+(?<format>[a-z0-9*\-.]+))?\z}

    accept = controller.request.headers["Accept"]
    return if accept.blank?

    match = accept.match(vendor_version_header_regex)
    return if match.blank?

    Gem::Version.new(match[:version])
  end
end
