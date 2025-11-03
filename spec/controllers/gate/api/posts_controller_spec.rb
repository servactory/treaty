# frozen_string_literal: true

RSpec.describe Gate::API::PostsController do
  render_views

  before { assign_json_headers_with(version:) }

  let(:version) { 3 }

  describe "#index" do
    subject(:perform) { get :index, params: }

    let(:params) do
      {
        filters: {
          title: "Understanding Kubernetes Pod Networking: A Deep Dive"
        }
      }
    end

    let(:expectation) do
      {
        post: {
          id: be_present & be_a(String),
          title: "Understanding Kubernetes Pod Networking: A Deep Dive",
          summary:
            "Explore how pods communicate in Kubernetes clusters and learn the fundamentals of CNI plugins, " \
            "network policies, and service mesh integration.",
          description:
            "This comprehensive guide breaks down the complex world of Kubernetes networking, " \
            "explaining how containers within pods share network namespaces and " \
            "how inter-pod communication works across nodes.",
          content: "..."
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
          post: {
            title: "Understanding Kubernetes Pod Networking: A Deep Dive",
            summary:
              "Explore how pods communicate in Kubernetes clusters and learn the fundamentals of CNI plugins, " \
              "network policies, and service mesh integration.",
            description:
              "This comprehensive guide breaks down the complex world of Kubernetes networking, " \
              "explaining how containers within pods share network namespaces and " \
              "how inter-pod communication works across nodes.",
            content: "..."
          }
        }
      end

      let(:expectation) do
        {
          post: {
            id: be_present & be_a(String),
            title: "Understanding Kubernetes Pod Networking: A Deep Dive",
            summary:
              "Explore how pods communicate in Kubernetes clusters and learn the fundamentals of CNI plugins, " \
              "network policies, and service mesh integration.",
            description:
              "This comprehensive guide breaks down the complex world of Kubernetes networking, " \
              "explaining how containers within pods share network namespaces and " \
              "how inter-pod communication works across nodes.",
            content: "..."
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
          post: {
            title: "Understanding Kubernetes Pod Networking: A Deep Dive",
            summary:
              "Explore how pods communicate in Kubernetes clusters and learn the fundamentals of CNI plugins, " \
              "network policies, and service mesh integration.",
            description:
              "This comprehensive guide breaks down the complex world of Kubernetes networking, " \
              "explaining how containers within pods share network namespaces and " \
              "how inter-pod communication works across nodes.",
            content: "..."
          }
        }
      end

      let(:expectation) do
        {
          post: {
            id: be_present & be_a(String),
            title: "Understanding Kubernetes Pod Networking: A Deep Dive",
            summary:
              "Explore how pods communicate in Kubernetes clusters and learn the fundamentals of CNI plugins, " \
              "network policies, and service mesh integration.",
            description:
              "This comprehensive guide breaks down the complex world of Kubernetes networking, " \
              "explaining how containers within pods share network namespaces and " \
              "how inter-pod communication works across nodes.",
            content: "..."
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
          post: {
            title: "Understanding Kubernetes Pod Networking: A Deep Dive",
            summary:
              "Explore how pods communicate in Kubernetes clusters and learn the fundamentals of CNI plugins, " \
              "network policies, and service mesh integration.",
            description:
              "This comprehensive guide breaks down the complex world of Kubernetes networking, " \
              "explaining how containers within pods share network namespaces and " \
              "how inter-pod communication works across nodes.",
            content: "...",
            author: {
              name: "John Doe",
              bio: "Senior DevOps Engineer specializing in Kubernetes and cloud infrastructure. " \
                   "Speaker and open-source contributor.",
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
            title: "Understanding Kubernetes Pod Networking: A Deep Dive",
            summary:
              "Explore how pods communicate in Kubernetes clusters and learn the fundamentals of CNI plugins, " \
              "network policies, and service mesh integration.",
            description:
              "This comprehensive guide breaks down the complex world of Kubernetes networking, " \
              "explaining how containers within pods share network namespaces and " \
              "how inter-pod communication works across nodes.",
            content: "..."
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
          post: {
            title: "Understanding Kubernetes Pod Networking: A Deep Dive",
            summary: nil,
            description:
              "This comprehensive guide breaks down the complex world of Kubernetes networking, " \
              "explaining how containers within pods share network namespaces and " \
              "how inter-pod communication works across nodes.",
            content: "...",
            author: {
              name: "John Doe",
              bio: "Senior DevOps Engineer specializing in Kubernetes and cloud infrastructure. " \
                   "Speaker and open-source contributor.",
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
      let(:version) { 3 }

      let(:params) do
        {
          # Query
          signature: "...",
          # Body
          post: {
            title: "Understanding Kubernetes Pod Networking: A Deep Dive",
            summary:
              "Explore how pods communicate in Kubernetes clusters and learn the fundamentals of CNI plugins, " \
              "network policies, and service mesh integration.",
            description:
              "This comprehensive guide breaks down the complex world of Kubernetes networking, " \
              "explaining how containers within pods share network namespaces and " \
              "how inter-pod communication works across nodes.",
            content: "...",
            author: {
              name: "John Doe",
              bio: "Senior DevOps Engineer specializing in Kubernetes and cloud infrastructure. " \
                   "Speaker and open-source contributor."
            },
            socials: [ # this is the wrong location
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
            message: "Attribute 'socials' not found in object 'author'"
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
