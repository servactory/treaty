# frozen_string_literal: true

RSpec.describe Treaty::Entity::Attribute::Option::Validators::RequiredValidator do
  subject(:validator) do
    described_class.new(
      attribute_name: :title,
      attribute_type: :string,
      option_schema:
    )
  end

  describe "#validate_schema!" do
    context "when required is true" do
      let(:option_schema) { { is: true, message: nil } }

      it "does not raise an error" do
        expect { validator.validate_schema! }.not_to raise_error
      end
    end

    context "when required is false" do
      let(:option_schema) { { is: false, message: nil } }

      it "does not raise an error" do
        expect { validator.validate_schema! }.not_to raise_error
      end
    end
  end

  describe "#validate_value!" do
    context "when required: true" do
      let(:option_schema) { { is: true, message: nil } }

      context "with present value" do
        it "does not raise error for non-empty string" do
          expect { validator.validate_value!("hello") }.not_to raise_error
        end

        it "does not raise error for non-empty array" do
          expect { validator.validate_value!([1, 2, 3]) }.not_to raise_error
        end

        it "does not raise error for non-empty hash" do
          expect { validator.validate_value!({ key: "value" }) }.not_to raise_error
        end

        it "does not raise error for integer" do
          expect { validator.validate_value!(123) }.not_to raise_error
        end

        it "does not raise error for false" do
          expect { validator.validate_value!(false) }.not_to raise_error
        end

        it "does not raise error for zero" do
          expect { validator.validate_value!(0) }.not_to raise_error
        end
      end

      context "with nil value" do
        it "raises validation error", :aggregate_failures do
          expect { validator.validate_value!(nil) }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to eq(
                "Attribute 'title' is required but was not provided or is empty"
              )
            end
          )
        end
      end

      context "with empty string" do
        it "raises validation error", :aggregate_failures do
          expect { validator.validate_value!("") }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to eq(
                "Attribute 'title' is required but was not provided or is empty"
              )
            end
          )
        end
      end

      context "with empty array" do
        it "raises validation error", :aggregate_failures do
          expect { validator.validate_value!([]) }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to eq(
                "Attribute 'title' is required but was not provided or is empty"
              )
            end
          )
        end
      end

      context "with empty hash" do
        it "raises validation error", :aggregate_failures do
          expect { validator.validate_value!({}) }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to eq(
                "Attribute 'title' is required but was not provided or is empty"
              )
            end
          )
        end
      end

      context "with custom error message" do
        let(:option_schema) { { is: true, message: "Title is mandatory" } }

        it "uses custom message" do
          expect { validator.validate_value!(nil) }.to(
            raise_error(Treaty::Exceptions::Validation, "Title is mandatory")
          )
        end
      end
    end

    context "when required: false" do
      let(:option_schema) { { is: false, message: nil } }

      it "does not raise error for nil value" do
        expect { validator.validate_value!(nil) }.not_to raise_error
      end

      it "does not raise error for empty string" do
        expect { validator.validate_value!("") }.not_to raise_error
      end

      it "does not raise error for empty array" do
        expect { validator.validate_value!([]) }.not_to raise_error
      end

      it "does not raise error for empty hash" do
        expect { validator.validate_value!({}) }.not_to raise_error
      end

      it "does not raise error for present value" do
        expect { validator.validate_value!("hello") }.not_to raise_error
      end
    end

    context "when option_schema is nil" do
      let(:option_schema) { nil }

      it "does not raise error for nil value (treated as optional)" do
        expect { validator.validate_value!(nil) }.not_to raise_error
      end

      it "does not raise error for empty value" do
        expect { validator.validate_value!("") }.not_to raise_error
      end
    end

    describe "edge cases" do
      let(:option_schema) { { is: true, message: nil } }

      it "does not raise error for whitespace string (not empty)" do
        expect { validator.validate_value!("   ") }.not_to raise_error
      end

      it "does not raise error for false boolean" do
        expect { validator.validate_value!(false) }.not_to raise_error
      end

      it "does not raise error for zero integer" do
        expect { validator.validate_value!(0) }.not_to raise_error
      end

      it "does not raise error for zero float" do
        expect { validator.validate_value!(0.0) }.not_to raise_error
      end
    end
  end
end
