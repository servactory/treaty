# frozen_string_literal: true

RSpec.describe UsersController do
  render_views

  describe "#index" do
    subject(:request) { get :index }

    let(:expectation) do
      {
        user: {
          id: be_present & be_a(String),
          first_name: "John",
          middle_name: nil,
          last_name: "Doe"
        }
      }
    end

    it "renders HTTP 200 OK" do
      expect(request).to have_http_status(:ok) & have_json_body(expectation)
    end
  end

  describe "#create" do
    subject(:request) { post :create, params: }

    let(:params) do
      {}
    end

    let(:expectation) do
      {
        user: {
          id: be_present & be_a(String),
          first_name: "John",
          middle_name: nil,
          last_name: "Doe"
        }
      }
    end

    it "renders HTTP 200 OK" do
      expect(request).to have_http_status(:ok) & have_json_body(expectation)
    end
  end
end
