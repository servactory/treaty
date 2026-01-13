# frozen_string_literal: true

RSpec.describe Treaty::Entity::Attribute::Option::Validators::TypeValidator do
  subject(:validator) do
    described_class.new(
      attribute_name:,
      attribute_type:,
      option_schema: nil
    )
  end

  let(:attribute_name) { :test_attribute }

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

    context "with allowed type :date" do
      let(:attribute_type) { :date }

      it "does not raise an error" do
        expect { validator.validate_schema! }.not_to raise_error
      end
    end

    context "with allowed type :time" do
      let(:attribute_type) { :time }

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

      it "raises validation error", :aggregate_failures do
        expect { validator.validate_schema! }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("unknown")
            expect(exception.message).to include("test_attribute")
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

      it "rejects String", :aggregate_failures do
        expect { validator.validate_value!("123") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
            expect(exception.message).to include("String")
          end
        )
      end

      it "rejects Float", :aggregate_failures do
        expect { validator.validate_value!(123.45) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
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

      it "rejects Integer", :aggregate_failures do
        expect { validator.validate_value!(123) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
            expect(exception.message).to include("Integer")
          end
        )
      end

      it "rejects Symbol", :aggregate_failures do
        expect { validator.validate_value!(:symbol) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
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

      it "rejects Integer 1", :aggregate_failures do
        expect { validator.validate_value!(1) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
            expect(exception.message).to include("Integer")
          end
        )
      end

      it "rejects Integer 0", :aggregate_failures do
        expect { validator.validate_value!(0) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
            expect(exception.message).to include("Integer")
          end
        )
      end

      it "rejects String 'true'", :aggregate_failures do
        expect { validator.validate_value!("true") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
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

      it "rejects Array", :aggregate_failures do
        expect { validator.validate_value!([1, 2, 3]) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
            expect(exception.message).to include("Array")
          end
        )
      end

      it "rejects String", :aggregate_failures do
        expect { validator.validate_value!("{}") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
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

      it "rejects Hash", :aggregate_failures do
        expect { validator.validate_value!({ key: "value" }) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
            expect(exception.message).to include("Hash")
          end
        )
      end

      it "rejects String", :aggregate_failures do
        expect { validator.validate_value!("[]") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
            expect(exception.message).to include("String")
          end
        )
      end
    end

    context "with type :date" do
      let(:attribute_type) { :date }

      it "accepts Date value" do
        expect { validator.validate_value!(Date.today) }.not_to raise_error
      end

      it "accepts nil (handled by RequiredValidator)" do
        expect { validator.validate_value!(nil) }.not_to raise_error
      end

      it "rejects DateTime", :aggregate_failures do
        expect { validator.validate_value!(DateTime.current) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
            expect(exception.message).to include("DateTime")
          end
        )
      end

      it "rejects Time", :aggregate_failures do
        expect { validator.validate_value!(Time.current) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
            expect(exception.message).to include("Time")
          end
        )
      end

      it "rejects String", :aggregate_failures do
        expect { validator.validate_value!("2025-01-15") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
            expect(exception.message).to include("String")
          end
        )
      end

      it "rejects Integer", :aggregate_failures do
        expect { validator.validate_value!(1_673_788_800) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
            expect(exception.message).to include("Integer")
          end
        )
      end
    end

    context "with type :time" do
      let(:attribute_type) { :time }

      it "accepts Time value" do
        expect { validator.validate_value!(Time.current) }.not_to raise_error
      end

      it "accepts nil (handled by RequiredValidator)" do
        expect { validator.validate_value!(nil) }.not_to raise_error
      end

      it "rejects DateTime", :aggregate_failures do
        expect { validator.validate_value!(DateTime.current) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
            expect(exception.message).to include("DateTime")
          end
        )
      end

      it "rejects Date", :aggregate_failures do
        expect { validator.validate_value!(Date.today) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
            expect(exception.message).to include("Date")
          end
        )
      end

      it "rejects String", :aggregate_failures do
        expect { validator.validate_value!("10:30:00") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
            expect(exception.message).to include("String")
          end
        )
      end

      it "rejects Integer", :aggregate_failures do
        expect { validator.validate_value!(1_673_788_800) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
            expect(exception.message).to include("Integer")
          end
        )
      end
    end

    context "with type :datetime" do
      let(:attribute_type) { :datetime }

      it "accepts DateTime value" do
        expect { validator.validate_value!(DateTime.current) }.not_to raise_error
      end

      it "accepts nil (handled by RequiredValidator)" do
        expect { validator.validate_value!(nil) }.not_to raise_error
      end

      it "rejects Time", :aggregate_failures do
        expect { validator.validate_value!(Time.current) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
            expect(exception.message).to include("Time")
          end
        )
      end

      it "rejects Date", :aggregate_failures do
        expect { validator.validate_value!(Date.today) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
            expect(exception.message).to include("Date")
          end
        )
      end

      it "rejects String", :aggregate_failures do
        expect { validator.validate_value!("2025-01-15") }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
            expect(exception.message).to include("String")
          end
        )
      end

      it "rejects Integer", :aggregate_failures do
        expect { validator.validate_value!(1_673_788_800) }.to(
          raise_error(Treaty::Exceptions::Validation) do |exception|
            expect(exception.message).to include("test_attribute")
            expect(exception.message).to include("Integer")
          end
        )
      end
    end
  end

  describe "custom type validation" do
    subject(:validator) do
      described_class.new(
        attribute_name:,
        attribute_type:,
        option_schema:
      )
    end

    let(:attribute_name) { :author }
    let(:attribute_type) { :object }

    let(:user_class) do
      Class.new do
        attr_reader :name, :email

        def initialize(name:, email:)
          @name = name
          @email = email
        end

        def self.name
          "User"
        end
      end
    end

    let(:admin_class) do
      Class.new do
        attr_reader :name, :permissions

        def initialize(name:, permissions:)
          @name = name
          @permissions = permissions
        end

        def self.name
          "Admin"
        end
      end
    end

    describe "#validate_schema!" do
      context "when type: option is used with object attribute" do
        let(:option_schema) { { is: user_class, message: nil } }

        it "does not raise an error" do
          expect { validator.validate_schema! }.not_to raise_error
        end
      end

      context "when type: option is used with non-object attribute" do
        let(:attribute_type) { :string }
        let(:option_schema) { { is: user_class, message: nil } }

        it "raises validation error", :aggregate_failures do
          expect { validator.validate_schema! }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to include("type:")
              expect(exception.message).to include("object")
              expect(exception.message).to include("string")
            end
          )
        end
      end

      context "when type: option is not a Class" do
        let(:option_schema) { { is: "User", message: nil } }

        it "raises validation error", :aggregate_failures do
          expect { validator.validate_schema! }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to include("type:")
              expect(exception.message).to include("Class")
            end
          )
        end
      end

      context "when type: option is nil (default Hash expected)" do
        let(:option_schema) { { is: nil, message: nil } }

        it "does not raise an error" do
          expect { validator.validate_schema! }.not_to raise_error
        end
      end
    end

    describe "#validate_value!" do
      context "with custom type option" do
        let(:option_schema) { { is: user_class, message: nil } }

        it "accepts instance of custom type" do
          user = user_class.new(name: "Alice", email: "alice@example.com")
          expect { validator.validate_value!(user) }.not_to raise_error
        end

        it "accepts nil (handled by RequiredValidator)" do
          expect { validator.validate_value!(nil) }.not_to raise_error
        end

        it "rejects instance of different class", :aggregate_failures do
          admin = admin_class.new(name: "Bob", permissions: %w[read write])
          expect { validator.validate_value!(admin) }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to include("author")
              expect(exception.message).to include("User")
              # Note: For anonymous classes, actual class shows as #<Class:0x...>
              # because Class#name returns nil for anonymous classes
            end
          )
        end

        it "rejects Hash", :aggregate_failures do
          expect { validator.validate_value!({ name: "Alice" }) }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to include("author")
              expect(exception.message).to include("User")
              expect(exception.message).to include("Hash")
            end
          )
        end

        it "rejects String", :aggregate_failures do
          expect { validator.validate_value!("Alice") }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to include("author")
              expect(exception.message).to include("User")
              expect(exception.message).to include("String")
            end
          )
        end
      end

      context "with custom error message" do
        let(:option_schema) { { is: user_class, message: "Must be a User instance" } }

        it "uses custom message on type mismatch" do
          expect { validator.validate_value!({ name: "Alice" }) }.to(
            raise_error(Treaty::Exceptions::Validation, "Must be a User instance")
          )
        end
      end

      context "with custom message as lambda" do
        let(:option_schema) do
          {
            is: user_class,
            message: ->(attribute:, actual:, **) { "#{attribute} requires User, got #{actual}" }
          }
        end

        it "evaluates lambda with context" do
          expect { validator.validate_value!({ name: "Alice" }) }.to(
            raise_error(Treaty::Exceptions::Validation, "author requires User, got Hash")
          )
        end
      end

      context "with anonymous class" do
        let(:anonymous_class) { Class.new }
        let(:option_schema) { { is: anonymous_class, message: nil } }

        it "accepts instance of anonymous class" do
          instance = anonymous_class.new
          expect { validator.validate_value!(instance) }.not_to raise_error
        end

        it "rejects different type with meaningful error" do
          expect { validator.validate_value!("test") }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to include("author")
            end
          )
        end
      end

      context "with Struct as custom type" do
        let(:user_struct) { Struct.new(:name, :email, keyword_init: true) }
        let(:option_schema) { { is: user_struct, message: nil } }

        it "accepts Struct instance" do
          user = user_struct.new(name: "Alice", email: "alice@example.com")
          expect { validator.validate_value!(user) }.not_to raise_error
        end

        it "rejects Hash" do
          expect { validator.validate_value!({ name: "Alice" }) }.to raise_error(Treaty::Exceptions::Validation)
        end
      end

      context "with Data class as custom type (Ruby 3.2+)" do
        let(:user_data) { Data.define(:name, :email) }
        let(:option_schema) { { is: user_data, message: nil } }

        it "accepts Data instance" do
          user = user_data.new(name: "Alice", email: "alice@example.com")
          expect { validator.validate_value!(user) }.not_to raise_error
        end

        it "rejects Hash" do
          expect { validator.validate_value!({ name: "Alice" }) }.to raise_error(Treaty::Exceptions::Validation)
        end
      end

      context "without custom type option (default Hash)" do
        let(:option_schema) { nil }

        it "accepts Hash" do
          expect { validator.validate_value!({ name: "Alice" }) }.not_to raise_error
        end

        it "rejects custom object", :aggregate_failures do
          user = user_class.new(name: "Alice", email: "alice@example.com")
          expect { validator.validate_value!(user) }.to(
            raise_error(Treaty::Exceptions::Validation) do |exception|
              expect(exception.message).to include("Hash")
            end
          )
        end
      end
    end
  end
end
