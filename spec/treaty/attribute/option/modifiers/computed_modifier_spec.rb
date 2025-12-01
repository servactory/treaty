# frozen_string_literal: true

RSpec.describe Treaty::Attribute::Option::Modifiers::ComputedModifier do
  subject(:modifier) do
    described_class.new(
      attribute_name: :test_attribute,
      attribute_type: :string,
      option_schema:
    )
  end

  describe "#validate_schema!" do
    context "when computed is a lambda" do
      let(:option_schema) { { is: ->(**attrs) { attrs.dig(:user, :name) }, message: nil } }

      it "does not raise an error" do
        expect { modifier.validate_schema! }.not_to raise_error
      end
    end

    context "when computed is a Proc" do
      let(:option_schema) { { is: proc { |**attrs| attrs.dig(:user, :name) }, message: nil } }

      it "does not raise an error" do
        expect { modifier.validate_schema! }.not_to raise_error
      end
    end

    context "when computed is not a Proc" do
      let(:option_schema) { { is: "not a proc", message: nil } }

      it "raises a validation error", :aggregate_failures do
        expect { modifier.validate_schema! }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to eq(
              "Option 'computed' for attribute 'test_attribute' must be a Proc or Lambda. Got: String"
            )
          end
        )
      end
    end
  end

  describe "#transform_value" do
    context "when computing full name from parts" do
      let(:option_schema) do
        {
          is: ->(**attrs) { "#{attrs.dig(:user, :first_name)} #{attrs.dig(:user, :last_name)}" },
          message: nil
        }
      end

      it "computes value from context data" do
        context = { user: { first_name: "John", last_name: "Doe" } }
        result = modifier.transform_value(nil, context)
        expect(result).to eq("John Doe")
      end

      it "ignores the passed value and always computes from context" do
        context = { user: { first_name: "Jane", last_name: "Smith" } }
        result = modifier.transform_value("ignored value", context)
        expect(result).to eq("Jane Smith")
      end
    end

    context "when computing word count from content" do
      let(:option_schema) do
        {
          is: ->(**attrs) { attrs.dig(:post, :content).to_s.split.size },
          message: nil
        }
      end

      it "computes word count" do
        context = { post: { content: "Hello world this is a test" } }
        result = modifier.transform_value(nil, context)
        expect(result).to eq(6)
      end

      it "handles nil content gracefully" do
        context = { post: { content: nil } }
        result = modifier.transform_value(nil, context)
        expect(result).to eq(0)
      end
    end

    context "when computing total from quantity and price" do
      let(:option_schema) do
        {
          is: ->(**attrs) { attrs.dig(:order, :quantity).to_i * attrs.dig(:order, :unit_price).to_i },
          message: nil
        }
      end

      it "computes total from multiplication" do
        context = { order: { quantity: 5, unit_price: 100 } }
        result = modifier.transform_value(nil, context)
        expect(result).to eq(500)
      end
    end

    context "when lambda raises an error" do
      let(:option_schema) { { is: ->(**attrs) { attrs.fetch(:missing_key) }, message: nil } }

      it "catches the error and raises Treaty::Exceptions::Validation", :aggregate_failures do
        expect { modifier.transform_value(nil, {}) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("Computed failed for attribute 'test_attribute'")
            expect(exception.message).to include("key not found")
          end
        )
      end
    end

    context "when custom error message is provided" do
      let(:option_schema) do
        {
          is: ->(**) { raise StandardError, "Custom error" },
          message: "Custom computed error for test_attribute"
        }
      end

      it "uses the custom message" do
        expect { modifier.transform_value(nil, {}) }.to(
          raise_error(Treaty::Exceptions::Validation, "Custom computed error for test_attribute")
        )
      end
    end

    context "when custom error message is a lambda" do
      let(:option_schema) do
        {
          is: ->(**) { raise StandardError, "original error" },
          message: ->(attribute:, error:) { "Computation failed for #{attribute}: #{error}" }
        }
      end

      it "evaluates the custom message lambda" do
        expect { modifier.transform_value(nil, {}) }.to(
          raise_error(
            Treaty::Exceptions::Validation,
            "Computation failed for test_attribute: original error"
          )
        )
      end
    end

    context "when accessing deeply nested data" do
      let(:option_schema) do
        {
          is: ->(**attrs) { attrs.dig(:order, :customer, :address, :city) },
          message: nil
        }
      end

      it "accesses deeply nested values" do
        context = { order: { customer: { address: { city: "New York" } } } }
        result = modifier.transform_value(nil, context)
        expect(result).to eq("New York")
      end

      it "returns nil for missing nested paths" do
        context = { order: {} }
        result = modifier.transform_value(nil, context)
        expect(result).to be_nil
      end
    end

    context "when accessing array data" do
      let(:option_schema) do
        {
          is: ->(**attrs) { attrs.dig(:post, :tags)&.join(", ") || "" },
          message: nil
        }
      end

      it "works with arrays in context" do
        context = { post: { tags: %w[ruby rails api] } }
        result = modifier.transform_value(nil, context)
        expect(result).to eq("ruby, rails, api")
      end
    end

    context "when value is already present" do
      let(:option_schema) do
        {
          is: ->(**attrs) { "computed: #{attrs.dig(:data, :value)}" },
          message: nil
        }
      end

      it "always computes, ignoring existing value" do
        context = { data: { value: "from_context" } }
        result = modifier.transform_value("existing_value", context)
        expect(result).to eq("computed: from_context")
      end
    end

    context "with empty context" do
      let(:option_schema) do
        {
          is: ->(**attrs) { attrs.dig(:user, :name) || "default" },
          message: nil
        }
      end

      it "handles empty context gracefully" do
        result = modifier.transform_value(nil, {})
        expect(result).to eq("default")
      end
    end
  end
end
