# frozen_string_literal: true

class Users::IndexTreaty < ApplicationTreaty
  version :v1 do
    strategy :direct

    # Query: filters[first_name], filters[middle_name], filters[last_name]
    request :filters do
      string :first_name, :string, :optional
      string :middle_name, :string, :optional
      string :last_name, :string, :optional
    end

    response :users, 200

    # Present: first_name, last_name. Missing: middle_name.
    delegate_to Users::V1::IndexService
  end

  version :v2 do
    strategy :adapter

    # Query: filters[first_name], filters[middle_name], filters[last_name]
    request :filters do
      string :first_name, :string, :optional
      string :middle_name, :string, :optional
      string :last_name, :string, :optional
    end

    response :users, 200 do
      string :id
      string :first_name
      string :middle_name
      string :last_name
    end

    delegate_to Users::Stable::IndexService
  end
end
