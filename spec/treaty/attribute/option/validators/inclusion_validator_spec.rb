# frozen_string_literal: true

RSpec.describe Treaty::Attribute::Option::Validators::InclusionValidator do
  subject(:validator) do
    described_class.new(
      attribute_name: :provider,
      attribute_type: :string,
      option_schema:
    )
  end

  describe "#validate_schema!" do
    context "with non-empty array" do
      let(:option_schema) { { in: %w[twitter linkedin github], message: nil } }

      it "does not raise an error" do
        expect { validator.validate_schema! }.not_to raise_error
      end
    end

    context "with array containing one element" do
      let(:option_schema) { { in: ["single"], message: nil } }

      it "does not raise an error" do
        expect { validator.validate_schema! }.not_to raise_error
      end
    end

    context "with empty array" do
      let(:option_schema) { { in: [], message: nil } }

      it "raises validation error", :aggregate_failures do
        expect { validator.validate_schema! }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("provider")
          end
        )
      end
    end

    context "with nil value" do
      let(:option_schema) { { in: nil, message: nil } }

      it "raises validation error", :aggregate_failures do
        expect { validator.validate_schema! }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("provider")
          end
        )
      end
    end

    context "with String value" do
      let(:option_schema) { { in: "twitter,linkedin,github", message: nil } }

      it "raises validation error", :aggregate_failures do
        expect { validator.validate_schema! }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("provider")
          end
        )
      end
    end

    context "with Integer value" do
      let(:option_schema) { { in: 123, message: nil } }

      it "raises validation error", :aggregate_failures do
        expect { validator.validate_schema! }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("provider")
          end
        )
      end
    end
  end

  describe "#validate_value!" do
    context "with string values" do
      let(:option_schema) { { in: %w[twitter linkedin github], message: nil } }

      it "accepts value in the list", :aggregate_failures do
        expect { validator.validate_value!("twitter") }.not_to raise_error
        expect { validator.validate_value!("linkedin") }.not_to raise_error
        expect { validator.validate_value!("github") }.not_to raise_error
      end

      it "accepts nil (handled by RequiredValidator)" do
        expect { validator.validate_value!(nil) }.not_to raise_error
      end

      it "rejects value not in the list", :aggregate_failures do
        expect { validator.validate_value!("facebook") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("provider")
            expect(exception.message).to include("facebook")
            expect(exception.message).to include("twitter, linkedin, github")
          end
        )
      end

      it "rejects empty string if not in the list", :aggregate_failures do
        expect { validator.validate_value!("") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("provider")
            expect(exception.message).to include("twitter, linkedin, github")
          end
        )
      end
    end

    context "with integer values" do
      let(:option_schema) { { in: [1, 2, 3, 5, 10], message: nil } }

      it "accepts value in the list", :aggregate_failures do
        expect { validator.validate_value!(1) }.not_to raise_error
        expect { validator.validate_value!(5) }.not_to raise_error
        expect { validator.validate_value!(10) }.not_to raise_error
      end

      it "rejects value not in the list", :aggregate_failures do
        expect { validator.validate_value!(4) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("provider")
            expect(exception.message).to include("4")
            expect(exception.message).to include("1, 2, 3, 5, 10")
          end
        )
      end
    end

    context "with symbol values" do
      let(:option_schema) { { in: %i[active inactive pending], message: nil } }

      it "accepts value in the list", :aggregate_failures do
        expect { validator.validate_value!(:active) }.not_to raise_error
        expect { validator.validate_value!(:inactive) }.not_to raise_error
        expect { validator.validate_value!(:pending) }.not_to raise_error
      end

      it "rejects value not in the list", :aggregate_failures do
        expect { validator.validate_value!(:deleted) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("provider")
            expect(exception.message).to include("deleted")
            expect(exception.message).to include("active, inactive, pending")
          end
        )
      end
    end

    context "with mixed type values" do
      let(:option_schema) { { in: [1, "two", :three, true], message: nil } }

      it "accepts integer from the list" do
        expect { validator.validate_value!(1) }.not_to raise_error
      end

      it "accepts string from the list" do
        expect { validator.validate_value!("two") }.not_to raise_error
      end

      it "accepts symbol from the list" do
        expect { validator.validate_value!(:three) }.not_to raise_error
      end

      it "accepts boolean from the list" do
        expect { validator.validate_value!(true) }.not_to raise_error
      end

      it "rejects value not in the list", :aggregate_failures do
        expect { validator.validate_value!(false) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("provider")
            expect(exception.message).to include("false")
          end
        )
      end
    end

    context "with custom error message" do
      let(:option_schema) { { in: %w[twitter linkedin github], message: "Invalid social provider" } }

      it "uses custom message" do
        expect { validator.validate_value!("facebook") }.to(
          raise_error(Treaty::Exceptions::Validation, "Invalid social provider")
        )
      end
    end

    describe "edge cases" do
      context "with boolean values" do
        let(:option_schema) { { in: [true, false], message: nil } }

        it "accepts true" do
          expect { validator.validate_value!(true) }.not_to raise_error
        end

        it "accepts false" do
          expect { validator.validate_value!(false) }.not_to raise_error
        end

        it "rejects string 'true'" do
          expect { validator.validate_value!("true") }.to(
            raise_error(Treaty::Exceptions::Validation)
          )
        end

        it "rejects integer 1" do
          expect { validator.validate_value!(1) }.to(
            raise_error(Treaty::Exceptions::Validation)
          )
        end
      end

      context "with single allowed value" do
        let(:option_schema) { { in: ["only_this"], message: nil } }

        it "accepts the only allowed value" do
          expect { validator.validate_value!("only_this") }.not_to raise_error
        end

        it "rejects any other value" do
          expect { validator.validate_value!("anything_else") }.to(
            raise_error(Treaty::Exceptions::Validation)
          )
        end
      end
    end
  end
end
