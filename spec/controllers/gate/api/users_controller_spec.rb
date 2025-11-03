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

    context "when version is 1" do
      let(:version) { 1 }

      let(:params) do
        {
          user: {
            first_name: "John",
            middle_name: nil,
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

    context "when version is 2" do
      let(:version) { 2 }

      let(:params) do
        {
          user: {
            first_name: "John",
            middle_name: nil,
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

    context "when version is 3" do
      let(:version) { 3 }

      let(:params) do
        {
          # Query
          signature: "...",
          # Body
          user: {
            first_name: "John",
            middle_name: nil,
            last_name: "Doe",
            address: {
              street: "123 Main St",
              city: "Anytown",
              state: "NY",
              zipcode: "12345"
            },
            socials: [
              {
                provider: "twitter",
                handle: "johndoe"
              }
            ]
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

    context "when version is unknown" do
      let(:version) { 999 }

      let(:params) do
        {
          # Query
          signature: "...",
          # Body
          user: {
            first_name: "John",
            middle_name: nil,
            last_name: nil,
            address: {
              street: "123 Main St",
              city: "Anytown",
              state: "NY",
              zipcode: "12345"
            },
            socials: [
              {
                provider: "twitter",
                handle: "johndoe"
              }
            ]
          }
        }
      end

      let(:expectation) do
        {
          error: {
            message: "Version 999 not found in treaty definition"
          }
        }
      end

      it "renders HTTP 422 Unprocessable Entity" do
        expect(perform).to(
          have_http_status(:unprocessable_content) &
          have_json_body(expectation)
        )
      end
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
end
