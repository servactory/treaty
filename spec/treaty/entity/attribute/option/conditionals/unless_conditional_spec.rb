# frozen_string_literal: true

RSpec.describe Treaty::Entity::Attribute::Option::Conditionals::UnlessConditional do
  subject(:conditional) do
    described_class.new(
      attribute_name: :test_attribute,
      attribute_type: :string,
      option_schema:
    )
  end

  describe "#validate_schema!" do
    context "when unless option is a Lambda" do
      let(:option_schema) { ->(post:) { post[:published_at].present? } }

      it "does not raise an error" do
        expect { conditional.validate_schema! }.not_to raise_error
      end
    end

    context "when unless option is a Proc" do
      let(:option_schema) { proc { |post:| post[:published_at].present? } }

      it "does not raise an error" do
        expect { conditional.validate_schema! }.not_to raise_error
      end
    end

    context "when unless option is a callable object" do
      let(:option_schema) do
        Class.new do
          def call(**_args)
            true
          end
        end.new
      end

      it "does not raise an error" do
        expect { conditional.validate_schema! }.not_to raise_error
      end
    end

    context "when unless option is not a callable" do
      context "with String" do
        let(:option_schema) { "not a lambda" }

        it "raises validation error", :aggregate_failures do
          expect { conditional.validate_schema! }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to eq(
                "Option 'unless' for attribute 'test_attribute' must be a Proc or Lambda. Got: String"
              )
            end
          )
        end
      end

      context "with Integer" do
        let(:option_schema) { 123 }

        it "raises validation error", :aggregate_failures do
          expect { conditional.validate_schema! }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to eq(
                "Option 'unless' for attribute 'test_attribute' must be a Proc or Lambda. Got: Integer"
              )
            end
          )
        end
      end

      context "with Boolean true" do
        let(:option_schema) { true }

        it "raises validation error", :aggregate_failures do
          expect { conditional.validate_schema! }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to eq(
                "Option 'unless' for attribute 'test_attribute' must be a Proc or Lambda. Got: TrueClass"
              )
            end
          )
        end
      end

      context "with Boolean false" do
        let(:option_schema) { false }

        it "raises validation error", :aggregate_failures do
          expect { conditional.validate_schema! }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to eq(
                "Option 'unless' for attribute 'test_attribute' must be a Proc or Lambda. Got: FalseClass"
              )
            end
          )
        end
      end

      context "with Hash" do
        let(:option_schema) { { is: true, message: "error" } }

        it "raises validation error", :aggregate_failures do
          expect { conditional.validate_schema! }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to eq(
                "Option 'unless' for attribute 'test_attribute' must be a Proc or Lambda. Got: Hash"
              )
            end
          )
        end
      end

      context "with Symbol" do
        let(:option_schema) { :some_method }

        it "raises validation error", :aggregate_failures do
          expect { conditional.validate_schema! }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to eq(
                "Option 'unless' for attribute 'test_attribute' must be a Proc or Lambda. Got: Symbol"
              )
            end
          )
        end
      end

      context "with nil" do
        let(:option_schema) { nil }

        it "raises validation error", :aggregate_failures do
          expect { conditional.validate_schema! }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to eq(
                "Option 'unless' for attribute 'test_attribute' must be a Proc or Lambda. Got: NilClass"
              )
            end
          )
        end
      end

      context "with Array" do
        let(:option_schema) { [1, 2, 3] }

        it "raises validation error", :aggregate_failures do
          expect { conditional.validate_schema! }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to eq(
                "Option 'unless' for attribute 'test_attribute' must be a Proc or Lambda. Got: Array"
              )
            end
          )
        end
      end
    end
  end

  describe "#evaluate_condition" do
    context "with keyword splat pattern (**attributes)" do
      let(:option_schema) { ->(**attributes) { attributes.dig(:post, :published_at).present? } }

      context "when condition evaluates to true" do
        let(:data) { { post: { published_at: Time.current } } }

        it "returns false" do
          result = conditional.evaluate_condition(data)
          expect(result).to be(false)
        end
      end

      context "when condition evaluates to false" do
        let(:data) { { post: { published_at: nil } } }

        it "returns true" do
          result = conditional.evaluate_condition(data)
          expect(result).to be(true)
        end
      end
    end

    context "with named argument pattern" do
      let(:option_schema) { ->(post:) { post[:published_at].present? } }

      context "when condition evaluates to true" do
        let(:data) { { post: { published_at: Time.current } } }

        it "returns false" do
          result = conditional.evaluate_condition(data)
          expect(result).to be(false)
        end
      end

      context "when condition evaluates to false" do
        let(:data) { { post: { published_at: nil } } }

        it "returns true" do
          result = conditional.evaluate_condition(data)
          expect(result).to be(true)
        end
      end
    end

    context "with multiple named arguments" do
      let(:option_schema) do
        ->(post:, user:) { post[:published_at].present? && user[:role] == "admin" }
      end

      context "when both conditions are true" do
        let(:data) do
          {
            post: { published_at: Time.current },
            user: { role: "admin" }
          }
        end

        it "returns false" do
          result = conditional.evaluate_condition(data)
          expect(result).to be(false)
        end
      end

      context "when one condition is false" do
        let(:data) do
          {
            post: { published_at: Time.current },
            user: { role: "user" }
          }
        end

        it "returns true" do
          result = conditional.evaluate_condition(data)
          expect(result).to be(true)
        end
      end
    end

    context "with truthy return values" do
      let(:data) { { post: {} } }

      context "when lambda returns true" do
        let(:option_schema) { ->(**_attrs) { true } }

        it "returns false" do
          result = conditional.evaluate_condition(data)
          expect(result).to be(false)
        end
      end

      context "when lambda returns non-empty string" do
        let(:option_schema) { ->(**_attrs) { "yes" } }

        it "returns false" do
          result = conditional.evaluate_condition(data)
          expect(result).to be(false)
        end
      end

      context "when lambda returns positive integer" do
        let(:option_schema) { ->(**_attrs) { 1 } }

        it "returns false" do
          result = conditional.evaluate_condition(data)
          expect(result).to be(false)
        end
      end

      context "when lambda returns non-empty array" do
        let(:option_schema) { ->(**_attrs) { [1, 2, 3] } }

        it "returns false" do
          result = conditional.evaluate_condition(data)
          expect(result).to be(false)
        end
      end

      context "when lambda returns non-empty hash" do
        let(:option_schema) { ->(**_attrs) { { key: "value" } } }

        it "returns false" do
          result = conditional.evaluate_condition(data)
          expect(result).to be(false)
        end
      end

      context "when lambda returns object" do
        let(:option_schema) { ->(**_attrs) { Object.new } }

        it "returns false" do
          result = conditional.evaluate_condition(data)
          expect(result).to be(false)
        end
      end
    end

    context "with falsy return values" do
      let(:data) { { post: {} } }

      context "when lambda returns false" do
        let(:option_schema) { ->(**_attrs) { false } }

        it "returns true" do
          result = conditional.evaluate_condition(data)
          expect(result).to be(true)
        end
      end

      context "when lambda returns nil" do
        let(:option_schema) { ->(**_attrs) {} }

        it "returns true" do
          result = conditional.evaluate_condition(data)
          expect(result).to be(true)
        end
      end
    end

    context "with edge cases" do
      context "when lambda returns empty string (truthy in Ruby)" do
        let(:option_schema) { ->(**_attrs) { "" } }
        let(:data) { { post: {} } }

        it "returns false (empty string is truthy)" do
          result = conditional.evaluate_condition(data)
          expect(result).to be(false)
        end
      end

      context "when lambda returns zero (truthy in Ruby)" do
        let(:option_schema) { ->(**_attrs) { 0 } }
        let(:data) { { post: {} } }

        it "returns false (zero is truthy)" do
          result = conditional.evaluate_condition(data)
          expect(result).to be(false)
        end
      end

      context "when lambda returns empty array (truthy in Ruby)" do
        let(:option_schema) { ->(**_attrs) { [] } }
        let(:data) { { post: {} } }

        it "returns false (empty array is truthy)" do
          result = conditional.evaluate_condition(data)
          expect(result).to be(false)
        end
      end

      context "when lambda returns empty hash (truthy in Ruby)" do
        let(:option_schema) { ->(**_attrs) { {} } }
        let(:data) { { post: {} } }

        it "returns false (empty hash is truthy)" do
          result = conditional.evaluate_condition(data)
          expect(result).to be(false)
        end
      end
    end

    context "when lambda raises an exception" do
      context "with NoMethodError" do
        let(:option_schema) { ->(post:) { post.non_existent_method } }
        let(:data) { { post: {} } }

        it "wraps exception in Validation error", :aggregate_failures do
          expect { conditional.evaluate_condition(data) }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to include("Conditional evaluation failed for attribute 'test_attribute'")
              expect(exception.message).to include("undefined method")
            end
          )
        end
      end

      context "with KeyError" do
        let(:option_schema) { ->(post:) { post.fetch(:missing_key) } }
        let(:data) { { post: {} } }

        it "wraps exception in Validation error", :aggregate_failures do
          expect { conditional.evaluate_condition(data) }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to include("Conditional evaluation failed for attribute 'test_attribute'")
              expect(exception.message).to include("key not found")
            end
          )
        end
      end

      context "with ArgumentError (missing required argument)" do
        let(:option_schema) { ->(post:, _user:) { post[:id] } }
        let(:data) { { post: { id: 1 } } } # missing user

        it "wraps exception in Validation error", :aggregate_failures do
          expect { conditional.evaluate_condition(data) }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to include("Conditional evaluation failed for attribute 'test_attribute'")
              expect(exception.message).to include("missing keyword")
            end
          )
        end
      end

      context "with StandardError" do
        let(:option_schema) { ->(**_attrs) { raise StandardError, "Custom error" } }
        let(:data) { { post: {} } }

        it "wraps exception in Validation error", :aggregate_failures do
          expect { conditional.evaluate_condition(data) }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to eq(
                "Conditional evaluation failed for attribute 'test_attribute': Custom error"
              )
            end
          )
        end
      end

      context "with RuntimeError" do
        let(:option_schema) { ->(**_attrs) { raise "Something went wrong" } }
        let(:data) { { post: {} } }

        it "wraps exception in Validation error", :aggregate_failures do
          expect { conditional.evaluate_condition(data) }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to eq(
                "Conditional evaluation failed for attribute 'test_attribute': Something went wrong"
              )
            end
          )
        end
      end

      context "with ZeroDivisionError" do
        let(:option_schema) { ->(**_attrs) { 1 / 0 } }
        let(:data) { { post: {} } }

        it "wraps exception in Validation error", :aggregate_failures do
          expect { conditional.evaluate_condition(data) }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to include("Conditional evaluation failed for attribute 'test_attribute'")
              expect(exception.message).to include("divided by")
            end
          )
        end
      end
    end

    context "with complex nested data" do
      let(:option_schema) do
        lambda do |**attributes|
          attributes.dig(:post, :metadata, :tags)&.include?("published") &&
            attributes.dig(:user, :permissions, :can_publish) == true
        end
      end

      context "when nested data matches condition" do
        let(:data) do
          {
            post: {
              metadata: { tags: %w[draft published] }
            },
            user: {
              permissions: { can_publish: true }
            }
          }
        end

        it "returns false" do
          result = conditional.evaluate_condition(data)
          expect(result).to be(false)
        end
      end

      context "when nested data doesn't match condition" do
        let(:data) do
          {
            post: {
              metadata: { tags: ["draft"] }
            },
            user: {
              permissions: { can_publish: true }
            }
          }
        end

        it "returns true" do
          result = conditional.evaluate_condition(data)
          expect(result).to be(true)
        end
      end
    end

    context "with safe navigation" do
      let(:option_schema) { ->(post:) { post&.dig(:published_at)&.present? } }

      context "when data is nil" do
        let(:data) { { post: nil } }

        it "returns true without raising error" do
          result = conditional.evaluate_condition(data)
          expect(result).to be(true)
        end
      end

      context "when nested value is nil" do
        let(:data) { { post: { published_at: nil } } }

        it "returns true without raising error" do
          result = conditional.evaluate_condition(data)
          expect(result).to be(true)
        end
      end
    end
  end

  describe "#validate_value!" do
    let(:option_schema) { ->(post:) { post[:published_at].present? } }

    context "when called with any value" do
      it "does not raise error for nil (no-op from Base)" do
        expect { conditional.validate_value!(nil) }.not_to raise_error
      end

      it "does not raise error for string" do
        expect { conditional.validate_value!("test") }.not_to raise_error
      end

      it "does not raise error for integer" do
        expect { conditional.validate_value!(123) }.not_to raise_error
      end
    end
  end

  describe "#transform_value" do
    let(:option_schema) { ->(post:) { post[:published_at].present? } }

    context "when called with any value" do
      it "returns value unchanged (pass-through from Base)" do
        result = conditional.transform_value("test")
        expect(result).to eq("test")
      end

      it "returns nil unchanged" do
        result = conditional.transform_value(nil)
        expect(result).to be_nil
      end

      it "returns integer unchanged" do
        result = conditional.transform_value(123)
        expect(result).to eq(123)
      end
    end
  end
end
