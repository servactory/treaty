# frozen_string_literal: true

RSpec::Matchers.define :have_json_body do |expected|
  match do |response|
    values_match?(expected, JSON.parse(response.body).with_indifferent_access)
  end

  failure_message do |response|
    "response body: " \
      "#{JSON.pretty_generate(JSON.parse(response.body))} " \
      "doesn't match with: " \
      "#{JSON.pretty_generate(expected)}"
  end

  description do
    "response #{expected.inspect}"
  end
end

RSpec::Matchers.alias_matcher :include_json, :have_json_body
