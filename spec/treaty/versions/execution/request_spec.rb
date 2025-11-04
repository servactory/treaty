# frozen_string_literal: true

RSpec.describe Treaty::Versions::Execution::Request do
  describe "#execute!" do
    let(:version_factory) do
      instance_double(
        Treaty::Versions::Factory,
        version: 3,
        executor: executor_instance
      )
    end
    let(:request) { described_class.new(version_factory:, validated_params:) }
    let(:validated_params) { { title: "Test Post" } }

    context "when executor is defined as a path-style string" do
      let(:executor_instance) do
        instance_double(
          Treaty::Versions::Executor,
          executor: "posts/stable/create_service",
          method: :call
        )
      end

      before do
        allow(Posts::Stable::CreateService).to(
          receive(:respond_to?)
            .with(:servactory?)
            .and_return(true)
        )
        allow(Posts::Stable::CreateService).to(
          receive_messages(
            servactory?: true,
            call: { success: true }
          )
        )
      end

      it "resolves the path-style string to a constant" do
        request.execute!

        expect(Posts::Stable::CreateService).to(
          have_received(:call)
            .with(params: validated_params)
        )
      end

      it "converts path segments to proper constant names" do
        expect { request.execute! }.not_to raise_error
      end
    end

    context "when executor is defined as a string with underscores" do
      let(:executor_instance) do
        instance_double(
          Treaty::Versions::Executor,
          executor: "posts/v1/create_service",
          method: :call
        )
      end

      before do
        allow(Posts::V1::CreateService).to(
          receive(:respond_to?)
            .with(:servactory?)
            .and_return(true)
        )
        allow(Posts::V1::CreateService).to(
          receive_messages(
            servactory?: true,
            call: { success: true }
          )
        )
      end

      it "converts snake_case to CamelCase correctly" do
        request.execute!

        expect(Posts::V1::CreateService).to(
          have_received(:call)
            .with(params: validated_params)
        )
      end
    end

    context "when executor is defined as a traditional constant string" do
      let(:executor_instance) do
        instance_double(
          Treaty::Versions::Executor,
          executor: "Posts::Stable::CreateService",
          method: :call
        )
      end

      before do
        allow(Posts::Stable::CreateService).to(
          receive(:respond_to?)
            .with(:servactory?)
            .and_return(true)
        )
        allow(Posts::Stable::CreateService).to(
          receive_messages(
            servactory?: true,
            call: { success: true }
          )
        )
      end

      it "resolves the constant string correctly" do
        request.execute!

        expect(Posts::Stable::CreateService).to(
          have_received(:call)
            .with(params: validated_params)
        )
      end
    end

    context "when executor is defined as a Class" do
      let(:executor_instance) do
        instance_double(
          Treaty::Versions::Executor,
          executor: Posts::Stable::CreateService,
          method: :call
        )
      end

      before do
        allow(Posts::Stable::CreateService).to(
          receive(:respond_to?)
            .with(:servactory?)
            .and_return(true)
        )
        allow(Posts::Stable::CreateService).to(
          receive_messages(
            servactory?: true,
            call: { success: true }
          )
        )
      end

      it "uses the class directly" do
        request.execute!

        expect(Posts::Stable::CreateService).to(
          have_received(:call)
            .with(params: validated_params)
        )
      end
    end

    context "when executor is defined as a Proc" do
      let(:executor_instance) do
        instance_double(
          Treaty::Versions::Executor,
          executor: executor_proc,
          method: :call
        )
      end
      let(:executor_proc) { ->(params:) { { result: params } } }

      before { allow(executor_proc).to receive(:call).and_call_original }

      it "executes the proc with validated params", :aggregate_failures do
        result = request.execute!

        expect(executor_proc).to(
          have_received(:call)
            .with(params: validated_params)
        )

        expect(result).to eq({ result: validated_params })
      end
    end

    context "when executor is a Servactory service" do
      let(:executor_instance) do
        instance_double(
          Treaty::Versions::Executor,
          executor: Posts::Stable::CreateService,
          method: :call
        )
      end
      let(:service_result) { { data: {} } }

      before do
        allow(Posts::Stable::CreateService).to(
          receive(:respond_to?)
            .with(:servactory?)
            .and_return(true)
        )
        allow(Posts::Stable::CreateService).to(
          receive_messages(
            servactory?: true,
            call: service_result
          )
        )
      end

      it "calls the service with params hash" do
        request.execute!

        expect(Posts::Stable::CreateService).to(
          have_received(:call)
            .with(params: validated_params)
        )
      end
    end

    context "when executor is an empty string" do
      let(:executor_instance) do
        instance_double(
          Treaty::Versions::Executor,
          executor: "",
          method: :call
        )
      end

      it "raises an Execution exception with a clear message", :aggregate_failures do
        expect { request.execute! }.to(
          raise_error do |exception|
            expect(exception).to be_a(Treaty::Exceptions::Execution)
            expect(exception.message).to(
              eq("Executor cannot be an empty string")
            )
          end
        )
      end
    end

    context "when executor path does not exist" do
      let(:executor_instance) do
        instance_double(
          Treaty::Versions::Executor,
          executor: "nonexistent/path/service",
          method: :call
        )
      end

      it "raises an Execution exception with a clear message", :aggregate_failures do
        expect { request.execute! }.to(
          raise_error do |exception|
            expect(exception).to be_a(Treaty::Exceptions::Execution)
            expect(exception.message).to(
              eq("Executor class `Nonexistent::Path::Service` not found")
            )
          end
        )
      end
    end

    context "when executor is nil" do
      let(:executor_instance) { nil }

      it "raises an Execution exception with a clear message", :aggregate_failures do
        expect { request.execute! }.to(
          raise_error do |exception|
            expect(exception).to be_a(Treaty::Exceptions::Execution)
            expect(exception.message).to(
              eq("Executor is not defined for version 3")
            )
          end
        )
      end
    end
  end

  describe "#normalize_constant_name" do
    let(:version_factory) do
      instance_double(
        Treaty::Versions::Factory,
        version: 3,
        executor: nil
      )
    end
    let(:request) { described_class.new(version_factory:, validated_params:) }
    let(:validated_params) { {} }

    context "with filesystem path format" do
      it "converts a simple path to constant name" do
        result = request.send(:normalize_constant_name, "posts/create_service")
        expect(result).to eq("Posts::CreateService")
      end

      it "converts a nested path to constant name" do
        result = request.send(:normalize_constant_name, "gate/api/posts/create_service")
        expect(result).to eq("Gate::API::Posts::CreateService")
      end

      it "converts path with version segments" do
        result = request.send(:normalize_constant_name, "posts/v1/create_service")
        expect(result).to eq("Posts::V1::CreateService")
      end

      it "handles symbols" do
        result = request.send(:normalize_constant_name, :"posts/stable/service")
        expect(result).to eq("Posts::Stable::Service")
      end
    end

    context "with constant format (::)" do
      it "preserves already formatted constant strings" do
        result = request.send(:normalize_constant_name, "Posts::Stable::CreateService")
        expect(result).to eq("Posts::Stable::CreateService")
      end

      it "preserves constant format with symbols" do
        result = request.send(:normalize_constant_name, :"Posts::Stable::CreateService")
        expect(result).to eq("Posts::Stable::CreateService")
      end
    end

    context "with simple class names" do
      it "handles single segment names" do
        result = request.send(:normalize_constant_name, "CreateService")
        expect(result).to eq("CreateService")
      end

      it "handles snake_case class names" do
        result = request.send(:normalize_constant_name, "create_service")
        expect(result).to eq("create_service")
      end
    end
  end
end
