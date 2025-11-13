# frozen_string_literal: true

module Gate
  module API
    module Languages
      class ShowTreaty < ApplicationTreaty
        version "1.0.0" do
          summary "Show Ruby feature details"

          strategy Treaty::Strategy::DIRECT

          deprecated true

          request do
            string :id
          end

          response 200 do
            object :feature
          end

          delegate_to ::Languages::V1::ShowService
        end

        version 2 do
          summary "Added usage examples"

          strategy Treaty::Strategy::ADAPTER

          deprecated do
            Gem::Version.new(ENV.fetch("RELEASE_VERSION", "0.0.0")) >=
              Gem::Version.new("5.0.0")
          end

          request do
            string :id
            boolean :include_examples, :optional
          end

          response 200 do
            object :feature do
              string :id
              string :name
              string :category
              string :description
              string :syntax

              array :examples, :optional do
                string :title
                string :code
                string :explanation
              end
            end
          end

          delegate_to "Languages::Stable::ShowService"
        end

        version 3, default: true do
          summary "Added gems and frameworks"

          strategy Treaty::Strategy::ADAPTER

          request do
            object :_self do
              boolean :detailed, :optional
            end
          end

          request do
            string :id
            boolean :include_examples, :optional
          end

          response 200 do
            object :feature do
              string :id
              string :name
              string :category
              string :paradigm
              string :description
              string :syntax
              boolean :experimental

              array :examples do
                string :title
                string :code
                string :explanation
                integer :complexity_level
              end

              object :ecosystem do
                array :gems do
                  string :name
                  string :purpose
                  string :repository, as: :repo_url
                end

                array :frameworks, :optional do
                  string :name
                  boolean :popular
                end

                array :tools, :optional do
                  string :_self
                end
              end

              datetime :introduced_at
              datetime :updated_at
            end
          end

          delegate_to "languages/stable/show_service"
        end
      end
    end
  end
end
