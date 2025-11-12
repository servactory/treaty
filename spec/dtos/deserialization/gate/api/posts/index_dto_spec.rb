# frozen_string_literal: true

RSpec.describe Deserialization::Gate::API::Posts::IndexDto do
  it_behaves_like "check treaty entity info",
                  attributes: {
                    filters: {
                      type: :object,
                      options: {
                        required: { is: false, message: nil }
                      },
                      attributes: {
                        description: {
                          type: :string,
                          options: {
                            required: { is: false, message: nil }
                          },
                          attributes: {}
                        },
                        summary: {
                          type: :string,
                          options: {
                            required: { is: false, message: nil }
                          },
                          attributes: {}
                        },
                        title: {
                          type: :string,
                          options: {
                            required: { is: false, message: nil }
                          },
                          attributes: {}
                        }
                      }
                    }
                  }
end
