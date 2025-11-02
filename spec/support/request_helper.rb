# frozen_string_literal: true

module RequestHelper
  def assign_json_headers_with(version:)
    # request.headers["Accept"] = "application/json"
    request.headers["Accept"] = "application/vnd.myapp-v#{version}+json"
    request.headers["Content-type"] = "application/json"
  end
end
