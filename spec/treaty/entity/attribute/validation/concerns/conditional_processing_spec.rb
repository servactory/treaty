# frozen_string_literal: true

RSpec.describe Treaty::Entity::Attribute::Validation::Concerns::ConditionalProcessing do
  # Test class that includes the module
  let(:test_class) do
    Class.new do
      include Treaty::Entity::Attribute::Validation::Concerns::ConditionalProcessing

      attr_reader :attribute

      def initialize(attribute)
        @attribute = attribute
      end

      # Expose private methods for testing
      def public_conditional_option_for(nested_attribute)
        conditional_option_for(nested_attribute)
      end

      def public_should_process_attribute?(nested_attribute, source_data)
        should_process_attribute?(nested_attribute, source_data)
      end

      def public_conditionals_for_attributes
        conditionals_for_attributes
      end
    end
  end

  let(:parent_attribute) do
    instance_double(
      Treaty::Entity::Attribute::Base,
      name: :post,
      collection_of_attributes: nested_attributes
    )
  end

  let(:nested_attributes) { [] }
  let(:processor) { test_class.new(parent_attribute) }

  describe "#conditional_option_for" do
    context "with :if option" do
      let(:nested_attribute) do
        instance_double(
          Treaty::Entity::Attribute::Base,
          name: :title,
          type: :string,
          options: { if: ->(post:) { post[:status] == "published" } }
        )
      end

      it "returns :if" do
        expect(processor.public_conditional_option_for(nested_attribute)).to eq(:if)
      end
    end

    context "with :unless option" do
      let(:nested_attribute) do
        instance_double(
          Treaty::Entity::Attribute::Base,
          name: :title,
          type: :string,
          options: { unless: ->(post:) { post[:draft] } }
        )
      end

      it "returns :unless" do
        expect(processor.public_conditional_option_for(nested_attribute)).to eq(:unless)
      end
    end

    context "without conditional option" do
      let(:nested_attribute) do
        instance_double(
          Treaty::Entity::Attribute::Base,
          name: :title,
          type: :string,
          options: { required: { is: true, message: nil } }
        )
      end

      it "returns nil" do
        expect(processor.public_conditional_option_for(nested_attribute)).to be_nil
      end
    end

    context "with both :if and :unless options" do
      let(:nested_attribute) do
        instance_double(
          Treaty::Entity::Attribute::Base,
          name: :title,
          type: :string,
          options: {
            if: ->(post:) { post[:status] == "published" },
            unless: ->(post:) { post[:draft] }
          }
        )
      end

      it "raises mutual exclusivity error" do
        expect do
          processor.public_conditional_option_for(nested_attribute)
        end.to raise_error(
          Treaty::Exceptions::Validation,
          /title.*if.*unless/i
        )
      end
    end
  end

  describe "#should_process_attribute?" do
    context "without conditional option" do
      let(:nested_attribute) do
        instance_double(
          Treaty::Entity::Attribute::Base,
          name: :title,
          type: :string,
          options: {}
        )
      end

      let(:nested_attributes) { [nested_attribute] }
      let(:source_data) { { status: "published" } }

      it "returns true" do
        expect(processor.public_should_process_attribute?(nested_attribute, source_data)).to be(true)
      end
    end

    context "with :if option that evaluates to true" do
      let(:nested_attribute) do
        instance_double(
          Treaty::Entity::Attribute::Base,
          name: :analytics,
          type: :object,
          options: { if: ->(post:) { post[:status] == "published" } }
        )
      end

      let(:nested_attributes) { [nested_attribute] }
      let(:source_data) { { status: "published" } }

      it "returns true" do
        expect(processor.public_should_process_attribute?(nested_attribute, source_data)).to be(true)
      end
    end

    context "with :if option that evaluates to false" do
      let(:nested_attribute) do
        instance_double(
          Treaty::Entity::Attribute::Base,
          name: :analytics,
          type: :object,
          options: { if: ->(post:) { post[:status] == "published" } }
        )
      end

      let(:nested_attributes) { [nested_attribute] }
      let(:source_data) { { status: "draft" } }

      it "returns false" do
        expect(processor.public_should_process_attribute?(nested_attribute, source_data)).to be(false)
      end
    end

    context "with :unless option that evaluates to false" do
      let(:nested_attribute) do
        instance_double(
          Treaty::Entity::Attribute::Base,
          name: :password,
          type: :string,
          options: { unless: ->(post:) { post[:public] } }
        )
      end

      let(:nested_attributes) { [nested_attribute] }
      let(:source_data) { { public: false } }

      it "returns true (attribute should be processed)" do
        expect(processor.public_should_process_attribute?(nested_attribute, source_data)).to be(true)
      end
    end

    context "with :unless option that evaluates to true" do
      let(:nested_attribute) do
        instance_double(
          Treaty::Entity::Attribute::Base,
          name: :password,
          type: :string,
          options: { unless: ->(post:) { post[:public] } }
        )
      end

      let(:nested_attributes) { [nested_attribute] }
      let(:source_data) { { public: true } }

      it "returns false (attribute should be skipped)" do
        expect(processor.public_should_process_attribute?(nested_attribute, source_data)).to be(false)
      end
    end

    context "when conditional evaluation raises error" do
      let(:nested_attribute) do
        instance_double(
          Treaty::Entity::Attribute::Base,
          name: :broken,
          type: :string,
          options: { if: ->(**) { raise "Broken!" } }
        )
      end

      let(:nested_attributes) { [nested_attribute] }
      let(:source_data) { { status: "published" } }

      it "returns false (skip attribute on error)" do
        expect(processor.public_should_process_attribute?(nested_attribute, source_data)).to be(false)
      end
    end
  end

  describe "#conditionals_for_attributes" do
    let(:nested_attribute_with_if) do
      instance_double(
        Treaty::Entity::Attribute::Base,
        name: :analytics,
        type: :object,
        options: { if: ->(post:) { post[:status] == "published" } }
      )
    end

    let(:nested_attribute_without_conditional) do
      instance_double(
        Treaty::Entity::Attribute::Base,
        name: :title,
        type: :string,
        options: {}
      )
    end

    let(:nested_attributes) { [nested_attribute_with_if, nested_attribute_without_conditional] }

    it "caches conditional processors" do
      first_call = processor.public_conditionals_for_attributes
      second_call = processor.public_conditionals_for_attributes

      expect(first_call).to be(second_call)
    end

    it "includes attributes with conditionals" do
      result = processor.public_conditionals_for_attributes

      expect(result.keys).to include(nested_attribute_with_if)
    end

    it "excludes attributes without conditionals" do
      result = processor.public_conditionals_for_attributes

      expect(result.keys).not_to include(nested_attribute_without_conditional)
    end
  end
end
