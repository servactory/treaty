# frozen_string_literal: true

module Languages
  module Stable
    class ShowService < ApplicationService::Base
      input :params, type: Hash, required: false, default: {}

      output :data, type: Hash

      private

      def call # rubocop:disable Metrics/MethodLength
        outputs.data = {
          feature: {
            id: inputs.params[:id] || SecureRandom.uuid,
            name: "Blocks",
            category: "syntax",
            paradigm: "functional",
            description: "Anonymous code blocks with yield",
            syntax: "{ |x| x * 2 }",
            experimental: false,
            examples: [
              {
                title: "Simple block",
                code: "[1, 2, 3].each { |n| puts n }",
                explanation: "Iterate over array",
                complexity_level: 1
              },
              {
                title: "Block with multiple params",
                code: "hash.each { |k, v| puts k }",
                explanation: "Iterate over hash",
                complexity_level: 2
              }
            ],
            ecosystem: {
              gems: [
                {
                  name: "rspec",
                  purpose: "Testing framework",
                  repo_url: "https://github.com/rspec/rspec"
                },
                {
                  name: "sinatra",
                  purpose: "Web framework",
                  repo_url: "https://github.com/sinatra/sinatra"
                }
              ],
              frameworks: [
                {
                  name: "Rails",
                  popular: true
                },
                {
                  name: "Hanami",
                  popular: false
                }
              ],
              tools: %w[rubocop reek]
            },
            introduced_at: Time.parse("2004-12-25"),
            updated_at: Time.current
          }
        }
      end
    end
  end
end
