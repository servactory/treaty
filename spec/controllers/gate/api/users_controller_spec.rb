# frozen_string_literal: true

RSpec.describe Gate::API::UsersController do
  render_views

  before { assign_json_headers_with(version:) }

  let(:version) { 3 }

  describe "#index" do
    subject(:perform) { get :index, params: }

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
      expect(perform).to(
        have_http_status(:ok) &
          have_json_body(expectation)
      )
    end
  end

  describe "#create" do
    subject(:perform) { post :create, params: }

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
      expect(perform).to(
        have_http_status(:ok) &
          have_json_body(expectation)
      )
    end
  end

  describe "#invalid_class" do
    subject(:perform) { get :invalid_class }

    let(:expectation) do
      {
        error: {
          message: "Invalid class name: Gate::API::Users::InvalidClassTreaty"
        }
      }
    end

    it "renders HTTP 500 Internal Server Error" do
      expect(perform).to(
        have_http_status(:internal_server_error) &
          have_json_body(expectation)
      )
    end
  end

  describe "#invalid_strategy" do
    subject(:perform) { get :invalid_strategy }

    let(:expectation) do
      {
        error: {
          message: "Unknown strategy: fake"
        }
      }
    end

    it "renders HTTP 500 Internal Server Error" do
      expect(perform).to(
        have_http_status(:internal_server_error) &
          have_json_body(expectation)
      )
    end
  end

  describe "#invalid_version_method" do
    subject(:perform) { get :invalid_version_method }

    let(:expectation) do
      {
        error: {
          message: "Unknown method: fake"
        }
      }
    end

    it "renders HTTP 500 Internal Server Error" do
      expect(perform).to(
        have_http_status(:internal_server_error) &
          have_json_body(expectation)
      )
    end
  end
end
