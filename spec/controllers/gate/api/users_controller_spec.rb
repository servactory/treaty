# frozen_string_literal: true

RSpec.describe Gate::API::UsersController do
  render_views

  describe "#index" do
    subject(:request) { get :index, params: }

    let(:params) do
      {
        filters: {
          first_name: "John"
        }
      }
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

  describe "#create" do
    subject(:request) { post :create, params: }

    let(:params) do
      {
        user: {
          first_name: "John",
          last_name: "Doe"
        }
      }
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

  describe "#invalid_class" do
    subject(:request) { get :invalid_class }

    it "renders HTTP 500 Internal Server Error" do
      expect(request).to have_http_status(:internal_server_error)
    end
  end
end
