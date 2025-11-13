# frozen_string_literal: true

module Gate
  module API
    module Languages
      class IndexTreaty < ApplicationTreaty
        version 1 do
          summary "List Ruby language features"

          strategy Treaty::Strategy::DIRECT

          request do
            object :filters, :optional do
              string :name, :optional
              string :category, :optional
            end
          end

          response 200 do
            array :features
            object :meta
          end

          delegate_to ::Languages::V1::IndexService
        end

        version 2 do
          summary "Added version filter and gems"

          strategy Treaty::Strategy::ADAPTER

          deprecated false

          request do
            object :filters, :optional do
              string :name, :optional
              string :category, :optional
              string :version, :optional
            end
          end

          response 200 do
            array :features do
              string :id
              string :name
              string :category
              string :description

              array :gems, :optional do
                string :_self
              end
            end

            object :meta do
              integer :count
              integer :page
            end
          end

          delegate_to ::Languages::Stable::IndexService
        end

        version 3, default: true do
          summary "Added paradigm and statistics"

          strategy Treaty::Strategy::ADAPTER

          request do
            object :filters, :optional do
              string :name, :optional
              string :category, :optional
              string :version, :optional
              string :paradigm, :optional, in: %w[functional imperative object-oriented]
            end
          end

          response 200 do
            array :features do
              string :id
              string :name
              string :category
              string :paradigm
              string :description

              array :gems do
                string :_self
              end

              object :statistics, :optional do
                integer :usage_count
                integer :popularity_score
              end

              datetime :introduced_at
            end

            object :meta do
              integer :count
              integer :page
              integer :limit, default: 20
            end
          end

          delegate_to "languages/stable/index_service"
        end
      end
    end
  end
end
