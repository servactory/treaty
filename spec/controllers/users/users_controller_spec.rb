# frozen_string_literal: true

RSpec.describe UsersController do
  render_views

  describe "#index" do
    subject(:request) { get :index }

    it "renders HTTP 200 OK" do
      expect(request).to have_http_status(:ok)
    end
  end

  describe "#create" do
    subject(:request) { post :create, params: }

    let(:params) do
      {}
    end

    it "renders HTTP 200 OK" do
      expect(request).to have_http_status(:ok)
    end
  end
end
