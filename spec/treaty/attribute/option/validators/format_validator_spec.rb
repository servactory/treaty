# frozen_string_literal: true

RSpec.describe Treaty::Attribute::Option::Validators::FormatValidator do
  subject(:validator) do
    described_class.new(
      attribute_name: :test_attr,
      attribute_type:,
      option_schema:
    )
  end

  describe "#validate_schema!" do
    context "with string type" do
      let(:attribute_type) { :string }

      context "with valid format :email" do
        let(:option_schema) { { is: :email, message: nil } }

        it "does not raise an error" do
          expect { validator.validate_schema! }.not_to raise_error
        end
      end

      context "with valid format :uuid" do
        let(:option_schema) { { is: :uuid, message: nil } }

        it "does not raise an error" do
          expect { validator.validate_schema! }.not_to raise_error
        end
      end

      context "with valid format :password" do
        let(:option_schema) { { is: :password, message: nil } }

        it "does not raise an error" do
          expect { validator.validate_schema! }.not_to raise_error
        end
      end

      context "with valid format :date" do
        let(:option_schema) { { is: :date, message: nil } }

        it "does not raise an error" do
          expect { validator.validate_schema! }.not_to raise_error
        end
      end

      context "with valid format :datetime" do
        let(:option_schema) { { is: :datetime, message: nil } }

        it "does not raise an error" do
          expect { validator.validate_schema! }.not_to raise_error
        end
      end

      context "with valid format :time" do
        let(:option_schema) { { is: :time, message: nil } }

        it "does not raise an error" do
          expect { validator.validate_schema! }.not_to raise_error
        end
      end

      context "with valid format :duration" do
        let(:option_schema) { { is: :duration, message: nil } }

        it "does not raise an error" do
          expect { validator.validate_schema! }.not_to raise_error
        end
      end

      context "with valid format :boolean" do
        let(:option_schema) { { is: :boolean, message: nil } }

        it "does not raise an error" do
          expect { validator.validate_schema! }.not_to raise_error
        end
      end

      context "with unknown format" do
        let(:option_schema) { { is: :unknown_format, message: nil } }

        it "raises validation error" do
          expect { validator.validate_schema! }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to include("test_attr")
              expect(exception.message).to include("unknown_format")
            end
          )
        end
      end
    end

    context "with non-string type" do
      let(:option_schema) { { is: :email, message: nil } }

      context "with integer type" do
        let(:attribute_type) { :integer }

        it "raises validation error" do
          expect { validator.validate_schema! }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to include("test_attr")
              expect(exception.message).to include("integer")
            end
          )
        end
      end

      context "with boolean type" do
        let(:attribute_type) { :boolean }

        it "raises validation error" do
          expect { validator.validate_schema! }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to include("test_attr")
              expect(exception.message).to include("boolean")
            end
          )
        end
      end
    end
  end

  describe "#validate_value!" do
    let(:attribute_type) { :string }

    context "with format :uuid" do
      let(:option_schema) { { is: :uuid, message: nil } }

      it "accepts valid UUID" do
        expect { validator.validate_value!("550e8400-e29b-41d4-a716-446655440000") }.not_to raise_error
        expect { validator.validate_value!("6ba7b810-9dad-11d1-80b4-00c04fd430c8") }.not_to raise_error
      end

      it "accepts nil" do
        expect { validator.validate_value!(nil) }.not_to raise_error
      end

      it "accepts empty string" do
        expect { validator.validate_value!("") }.not_to raise_error
        expect { validator.validate_value!("   ") }.not_to raise_error
      end

      it "rejects invalid UUID" do
        expect { validator.validate_value!("not-a-uuid") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attr")
            expect(exception.message).to include("not-a-uuid")
          end
        )
      end

      it "rejects UUID without dashes" do
        expect { validator.validate_value!("550e8400e29b41d4a716446655440000") }.to(
          raise_error(Treaty::Exceptions::Validation)
        )
      end
    end

    context "with format :email" do
      let(:option_schema) { { is: :email, message: nil } }

      it "accepts valid email" do
        expect { validator.validate_value!("user@example.com") }.not_to raise_error
        expect { validator.validate_value!("john.doe@company.co.uk") }.not_to raise_error
      end

      it "accepts nil" do
        expect { validator.validate_value!(nil) }.not_to raise_error
      end

      it "rejects invalid email" do
        expect { validator.validate_value!("not-an-email") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attr")
            expect(exception.message).to include("not-an-email")
          end
        )
      end

      it "rejects email without @" do
        expect { validator.validate_value!("userexample.com") }.to(
          raise_error(Treaty::Exceptions::Validation)
        )
      end
    end

    context "with format :password" do
      let(:option_schema) { { is: :password, message: nil } }

      it "accepts valid password" do
        expect { validator.validate_value!("Password1") }.not_to raise_error
        expect { validator.validate_value!("Abcd1234") }.not_to raise_error
        expect { validator.validate_value!("Test1234Pass") }.not_to raise_error
      end

      it "accepts nil" do
        expect { validator.validate_value!(nil) }.not_to raise_error
      end

      it "rejects password without uppercase" do
        expect { validator.validate_value!("password1") }.to(
          raise_error(Treaty::Exceptions::Validation)
        )
      end

      it "rejects password without lowercase" do
        expect { validator.validate_value!("PASSWORD1") }.to(
          raise_error(Treaty::Exceptions::Validation)
        )
      end

      it "rejects password without digit" do
        expect { validator.validate_value!("Password") }.to(
          raise_error(Treaty::Exceptions::Validation)
        )
      end

      it "rejects password too short" do
        expect { validator.validate_value!("Pass1") }.to(
          raise_error(Treaty::Exceptions::Validation)
        )
      end

      it "rejects password too long" do
        expect { validator.validate_value!("Password123456789") }.to(
          raise_error(Treaty::Exceptions::Validation)
        )
      end
    end

    context "with format :date" do
      let(:option_schema) { { is: :date, message: nil } }

      it "accepts valid date" do
        expect { validator.validate_value!("2025-01-15") }.not_to raise_error
        expect { validator.validate_value!("2024-12-31") }.not_to raise_error
      end

      it "accepts various date formats" do
        expect { validator.validate_value!("15/01/2025") }.not_to raise_error  # DD/MM/YYYY
        expect { validator.validate_value!("2025/01/15") }.not_to raise_error  # YYYY/MM/DD
      end

      it "accepts nil" do
        expect { validator.validate_value!(nil) }.not_to raise_error
      end

      it "rejects invalid date" do
        expect { validator.validate_value!("not-a-date") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attr")
            expect(exception.message).to include("not-a-date")
          end
        )
      end
    end

    context "with format :datetime" do
      let(:option_schema) { { is: :datetime, message: nil } }

      it "accepts valid datetime" do
        expect { validator.validate_value!("2025-01-15T10:30:00Z") }.not_to raise_error
        expect { validator.validate_value!("2024-12-31 23:59:59") }.not_to raise_error
      end

      it "accepts nil" do
        expect { validator.validate_value!(nil) }.not_to raise_error
      end

      it "rejects invalid datetime" do
        expect { validator.validate_value!("not-a-datetime") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attr")
            expect(exception.message).to include("not-a-datetime")
          end
        )
      end
    end

    context "with format :time" do
      let(:option_schema) { { is: :time, message: nil } }

      it "accepts valid time" do
        expect { validator.validate_value!("10:30:00") }.not_to raise_error
        expect { validator.validate_value!("23:59:59") }.not_to raise_error
        expect { validator.validate_value!("10:30 AM") }.not_to raise_error
      end

      it "accepts nil" do
        expect { validator.validate_value!(nil) }.not_to raise_error
      end

      it "rejects invalid time" do
        expect { validator.validate_value!("not-a-time") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attr")
            expect(exception.message).to include("not-a-time")
          end
        )
      end
    end

    context "with format :duration" do
      let(:option_schema) { { is: :duration, message: nil } }

      it "accepts valid duration" do
        expect { validator.validate_value!("P1D") }.not_to raise_error      # 1 day
        expect { validator.validate_value!("PT2H") }.not_to raise_error     # 2 hours
        expect { validator.validate_value!("PT30M") }.not_to raise_error    # 30 minutes
        expect { validator.validate_value!("P1W") }.not_to raise_error      # 1 week
        expect { validator.validate_value!("PT1H30M") }.not_to raise_error  # 1 hour 30 minutes
      end

      it "accepts nil" do
        expect { validator.validate_value!(nil) }.not_to raise_error
      end

      it "rejects invalid duration" do
        expect { validator.validate_value!("not-a-duration") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attr")
            expect(exception.message).to include("not-a-duration")
          end
        )
      end

      it "rejects non-ISO 8601 duration format" do
        expect { validator.validate_value!("1 day") }.to(
          raise_error(Treaty::Exceptions::Validation)
        )
      end
    end

    context "with format :boolean" do
      let(:option_schema) { { is: :boolean, message: nil } }

      it "accepts valid boolean strings" do
        expect { validator.validate_value!("true") }.not_to raise_error
        expect { validator.validate_value!("false") }.not_to raise_error
        expect { validator.validate_value!("0") }.not_to raise_error
        expect { validator.validate_value!("1") }.not_to raise_error
        expect { validator.validate_value!("TRUE") }.not_to raise_error
        expect { validator.validate_value!("FALSE") }.not_to raise_error
      end

      it "accepts nil" do
        expect { validator.validate_value!(nil) }.not_to raise_error
      end

      it "rejects invalid boolean strings" do
        expect { validator.validate_value!("yes") }.to(
          raise_error(Treaty::Exceptions::Validation)
        )
        expect { validator.validate_value!("no") }.to(
          raise_error(Treaty::Exceptions::Validation)
        )
        expect { validator.validate_value!("2") }.to(
          raise_error(Treaty::Exceptions::Validation)
        )
      end
    end

    context "with custom error message" do
      let(:option_schema) { { is: :email, message: "Invalid email format" } }

      it "uses custom message" do
        expect { validator.validate_value!("not-an-email") }.to(
          raise_error(Treaty::Exceptions::Validation, "Invalid email format")
        )
      end
    end
  end
end
