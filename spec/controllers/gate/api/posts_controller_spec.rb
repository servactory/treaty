# frozen_string_literal: true

RSpec.describe Gate::API::PostsController do
  render_views

  before { assign_json_headers_with(version:) }

  let(:version) { "3" }

  describe "#index" do
    subject(:perform) { get :index, params: }

    context "when version is 1.0.0.rc1" do
      let(:version) { "1.0.0.rc1" }

      let(:params) do
        {
          filters: {
            title: "Title 1"
          }
        }
      end

      let(:expectation) do
        {
          error: {
            message: "Version 1.0.0.rc1 is deprecated and cannot be used"
          }
        }
      end

      it "renders HTTP 410 Gone" do
        expect(perform).to(
          have_http_status(:gone) &
          have_json_body(expectation)
        )
      end
    end

    context "when version is 1.0.0.rc2" do
      let(:version) { "1.0.0.rc2" }

      let(:params) do
        {
          filters: {
            title: "Title 1"
          }
        }
      end

      let(:expectation) do
        {
          error: {
            message: "Version 1.0.0.rc2 is deprecated and cannot be used"
          }
        }
      end

      it "renders HTTP 410 Gone" do
        expect(perform).to(
          have_http_status(:gone) &
          have_json_body(expectation)
        )
      end
    end

    context "when version is 3" do
      let(:version) { "3" }

      let(:params) do
        {
          filters: {
            title: "Title 1"
          }
        }
      end

      let(:expectation) do
        {
          posts: [
            {
              id: be_present & be_a(String),
              title: "Title 1",
              summary: "Summary 1",
              description: "Description 1",
              content: "..."
            }
          ],
          meta: {
            count: 1,
            page: 1,
            limit: 10
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
  end

  describe "#create" do
    subject(:perform) { post :create, params: }

    context "when version is 1" do
      let(:version) { "1" }

      let(:params) do
        {
          post: {
            title: "Title 1",
            summary: "Summary 1",
            description: "Description 1",
            content: "..."
          }
        }
      end

      let(:expectation) do
        {
          post: {
            id: be_present & be_a(String),
            title: "Title 1",
            summary: "Summary 1",
            description: "Description 1",
            content: "..."
          }
        }
      end

      it "renders HTTP 201 Created" do
        expect(perform).to(
          have_http_status(:created) &
          have_json_body(expectation)
        )
      end
    end

    context "when version is 2" do
      let(:version) { "2" }

      let(:params) do
        {
          post: {
            title: "Title 1",
            summary: "Summary 1",
            description: "Description 1",
            content: "..."
          }
        }
      end

      let(:expectation) do
        {
          post: {
            id: be_present & be_a(String),
            title: "Title 1",
            summary: "Summary 1",
            description: "Description 1",
            content: "..."
          }
        }
      end

      it "renders HTTP 201 Created" do
        expect(perform).to(
          have_http_status(:created) &
          have_json_body(expectation)
        )
      end
    end

    context "when version is 3" do
      let(:version) { "3" }

      let(:params) do
        {
          # Query
          signature: "...",
          # Body
          post: {
            title: "Title 1",
            summary: "Summary 1",
            description: "Description 1",
            content: "...",
            tags: %w[tag1 tag2 tag3],
            author: {
              name: "John Doe",
              bio: "...",
              socials: [
                {
                  provider: "twitter",
                  handle: "johndoe"
                }
              ]
            }
          }
        }
      end

      let(:expectation) do
        {
          post: {
            id: be_present & be_a(String),
            title: "Title 1",
            summary: "Summary 1",
            description: "Description 1",
            content: "...",
            published: nil,
            featured: nil,
            tags: %w[tag1 tag2 tag3],
            author: {
              name: "John Doe",
              bio: "...",
              socials: [
                {
                  provider: "twitter",
                  handle: "johndoe"
                }
              ]
            },
            rating: 0,
            views: 0,
            created_at: be_present & be_a(String),
            updated_at: be_present & be_a(String)
          }
        }
      end

      it "renders HTTP 201 Created" do
        expect(perform).to(
          have_http_status(:created) &
          have_json_body(expectation)
        )
      end
    end

    context "when version is unknown" do
      let(:version) { "999" }

      let(:params) do
        {
          # Query
          signature: "...",
          # Body
          post: {
            title: "Title 1",
            summary: nil,
            description: "Description 1",
            content: "...",
            author: {
              name: "John Doe",
              bio: "...",
              socials: [
                {
                  provider: "twitter",
                  handle: "johndoe"
                }
              ]
            }
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

    context "when there is incorrect field" do
      let(:version) { "3" }

      let(:params) do
        {
          # Query
          signature: "...",
          # Body
          post: {
            title: "Title 1",
            summary: "Summary 1",
            description: "Description 1",
            content: "...",
            author: {
              name: "John Doe"
              # Missing required 'bio' field.
            }
          }
        }
      end

      let(:expectation) do
        {
          error: {
            message: "Attribute 'bio' is required but was not provided or is empty"
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
          message: "Invalid class name: Gate::API::Posts::InvalidClassTreaty"
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
