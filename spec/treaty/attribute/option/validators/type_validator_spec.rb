# frozen_string_literal: true

RSpec.describe Treaty::Attribute::Option::Validators::TypeValidator do
  subject(:validator) do
    described_class.new(
      attribute_name:,
      attribute_type:,
      option_schema: nil
    )
  end

  let(:attribute_name) { :test_attr }

  describe "#validate_schema!" do
    context "with allowed type :integer" do
      let(:attribute_type) { :integer }

      it "does not raise an error" do
        expect { validator.validate_schema! }.not_to raise_error
      end
    end

    context "with allowed type :string" do
      let(:attribute_type) { :string }

      it "does not raise an error" do
        expect { validator.validate_schema! }.not_to raise_error
      end
    end

    context "with allowed type :boolean" do
      let(:attribute_type) { :boolean }

      it "does not raise an error" do
        expect { validator.validate_schema! }.not_to raise_error
      end
    end

    context "with allowed type :object" do
      let(:attribute_type) { :object }

      it "does not raise an error" do
        expect { validator.validate_schema! }.not_to raise_error
      end
    end

    context "with allowed type :array" do
      let(:attribute_type) { :array }

      it "does not raise an error" do
        expect { validator.validate_schema! }.not_to raise_error
      end
    end

    context "with allowed type :datetime" do
      let(:attribute_type) { :datetime }

      it "does not raise an error" do
        expect { validator.validate_schema! }.not_to raise_error
      end
    end

    context "with unknown type :unknown" do
      let(:attribute_type) { :unknown }

      it "raises validation error" do
        expect { validator.validate_schema! }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("unknown")
            expect(exception.message).to include("test_attr")
          end
        )
      end
    end
  end

  describe "#validate_value!" do
    context "with type :integer" do
      let(:attribute_type) { :integer }

      it "accepts Integer value" do
        expect { validator.validate_value!(123) }.not_to raise_error
      end

      it "accepts negative Integer" do
        expect { validator.validate_value!(-456) }.not_to raise_error
      end

      it "accepts zero" do
        expect { validator.validate_value!(0) }.not_to raise_error
      end

      it "accepts nil (handled by RequiredValidator)" do
        expect { validator.validate_value!(nil) }.not_to raise_error
      end

      it "rejects String" do
        expect { validator.validate_value!("123") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attr")
            expect(exception.message).to include("String")
          end
        )
      end

      it "rejects Float" do
        expect { validator.validate_value!(123.45) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attr")
            expect(exception.message).to include("Float")
          end
        )
      end
    end

    context "with type :string" do
      let(:attribute_type) { :string }

      it "accepts String value" do
        expect { validator.validate_value!("hello") }.not_to raise_error
      end

      it "accepts empty String" do
        expect { validator.validate_value!("") }.not_to raise_error
      end

      it "accepts nil (handled by RequiredValidator)" do
        expect { validator.validate_value!(nil) }.not_to raise_error
      end

      it "rejects Integer" do
        expect { validator.validate_value!(123) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attr")
            expect(exception.message).to include("Integer")
          end
        )
      end

      it "rejects Symbol" do
        expect { validator.validate_value!(:symbol) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attr")
            expect(exception.message).to include("Symbol")
          end
        )
      end
    end

    context "with type :boolean" do
      let(:attribute_type) { :boolean }

      it "accepts true" do
        expect { validator.validate_value!(true) }.not_to raise_error
      end

      it "accepts false" do
        expect { validator.validate_value!(false) }.not_to raise_error
      end

      it "accepts nil (handled by RequiredValidator)" do
        expect { validator.validate_value!(nil) }.not_to raise_error
      end

      it "rejects Integer 1" do
        expect { validator.validate_value!(1) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attr")
            expect(exception.message).to include("Integer")
          end
        )
      end

      it "rejects Integer 0" do
        expect { validator.validate_value!(0) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attr")
            expect(exception.message).to include("Integer")
          end
        )
      end

      it "rejects String 'true'" do
        expect { validator.validate_value!("true") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attr")
            expect(exception.message).to include("String")
          end
        )
      end
    end

    context "with type :object" do
      let(:attribute_type) { :object }

      it "accepts Hash value" do
        expect { validator.validate_value!({ key: "value" }) }.not_to raise_error
      end

      it "accepts empty Hash" do
        expect { validator.validate_value!({}) }.not_to raise_error
      end

      it "accepts nil (handled by RequiredValidator)" do
        expect { validator.validate_value!(nil) }.not_to raise_error
      end

      it "rejects Array" do
        expect { validator.validate_value!([1, 2, 3]) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attr")
            expect(exception.message).to include("Array")
          end
        )
      end

      it "rejects String" do
        expect { validator.validate_value!("{}") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attr")
            expect(exception.message).to include("String")
          end
        )
      end
    end

    context "with type :array" do
      let(:attribute_type) { :array }

      it "accepts Array value" do
        expect { validator.validate_value!([1, 2, 3]) }.not_to raise_error
      end

      it "accepts empty Array" do
        expect { validator.validate_value!([]) }.not_to raise_error
      end

      it "accepts nil (handled by RequiredValidator)" do
        expect { validator.validate_value!(nil) }.not_to raise_error
      end

      it "rejects Hash" do
        expect { validator.validate_value!({ key: "value" }) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attr")
            expect(exception.message).to include("Hash")
          end
        )
      end

      it "rejects String" do
        expect { validator.validate_value!("[]") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attr")
            expect(exception.message).to include("String")
          end
        )
      end
    end

    context "with type :datetime" do
      let(:attribute_type) { :datetime }

      it "accepts DateTime value" do
        expect { validator.validate_value!(DateTime.now) }.not_to raise_error
      end

      it "accepts Time value" do
        expect { validator.validate_value!(Time.now) }.not_to raise_error
      end

      it "accepts Date value" do
        expect { validator.validate_value!(Date.today) }.not_to raise_error
      end

      it "accepts nil (handled by RequiredValidator)" do
        expect { validator.validate_value!(nil) }.not_to raise_error
      end

      it "rejects String" do
        expect { validator.validate_value!("2025-01-15") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attr")
            expect(exception.message).to include("String")
          end
        )
      end

      it "rejects Integer" do
        expect { validator.validate_value!(1_673_788_800) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attr")
            expect(exception.message).to include("Integer")
          end
        )
      end
    end
  end
end
