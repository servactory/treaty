# frozen_string_literal: true

module RequestHelper
  def assign_json_headers
    # request.headers["Accept"] = "application/json"
    request.headers["Accept"] = "application/vnd.myapp-v1+json"
    request.headers["Content-type"] = "application/json"
  end
end
