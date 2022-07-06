# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AttributeObject::Form do
    subject { form.new(attributes) }

    let(:form) do
      c = Class.new(described_class) do
        mimic :person

        attribute :name, String
        attribute :email, String
        attribute :boss, const_get(:Boolean), default: false

        attribute :any

        validates :name, presence: true
        validates :email, presence: true
      end

      c.attribute :drinks, Array[drinkform]
      c.attribute(:foods, { Symbol => foodform })
      c.attribute :gadgets, Array[gadgetmodel]

      c
    end
    let(:drinkform) do
      Class.new(described_class) do
        mimic :drink

        attribute :name, String

        validates :name, presence: true

        attr_reader :secret_sauce

        def map_model(model)
          @secret_sauce = model.custom_sauce
        end
      end
    end
    let(:foodform) do
      # Extends drinkform
      Class.new(drinkform) do
        mimic :food

        attribute :vegan, const_get(:Boolean), default: false
      end
    end
    let(:gadgetmodel) do
      Class.new do
        include ActiveModel::Model

        attr_accessor :brand, :name

        validates :brand, presence: true
        validates :name, presence: true

        def self.model_name
          ActiveModel::Name.new(self, nil, "Gadget")
        end
      end
    end
    let(:attributes) { valid_attributes }
    let(:valid_attributes) do
      {
        id: 1,
        name: "John",
        email: "john@example.org",
        boss: true,
        drinks: [{ name: "Water" }, { name: "Cola" }, { name: "Beer" }],
        foods: { meatballs: { name: "Meatballs" }, voner: { name: "Vöner", vegan: true } },
        gadgets: [gadgetmodel.new(brand: "Pear", name: "myFone"), gadgetmodel.new(brand: "Sahara", name: "Quench")]
      }
    end

    describe ".mimic" do
      subject do
        c = Class.new(described_class)
        c.mimic(mimicked_name)
        c
      end

      let(:mimicked_name) { :foo }

      it "sets the mimicked model name correctly" do
        expect(subject.mimicked_model_name).to be(:foo)
      end

      context "with a String" do
        let(:mimicked_name) { "Test::FooBar" }

        it "converts the mimicked model name correctly" do
          expect(subject.mimicked_model_name).to be(:"test/foo_bar")
        end
      end

      context "with a constant" do
        let(:mimicked_name) { Decidim::DummyResources::DummyResource }

        it "converts the mimicked model name correctly" do
          expect(subject.mimicked_model_name).to be(:"decidim/dummy_resources/dummy_resource")
        end
      end
    end

    describe ".mimicked_model_name" do
      subject { Class.new(described_class) }

      it "calls infer_model_name when the mimicked name is not set" do
        name = double
        allow(subject).to receive(:infer_model_name).and_return(name)
        expect(subject.mimicked_model_name).to eq(name)
      end

      it "returns the mimicked name when it is set" do
        name = double
        subject.instance_variable_set(:@model_name, name)
        expect(subject.mimicked_model_name).to eq(name)
      end
    end

    describe ".infer_model_name" do
      subject { Class.new(described_class) }

      it "returns :form when the name is not set" do
        expect(subject.infer_model_name).to be(:form)
      end

      it "returns the converted name when it is set" do
        expect(subject).to receive(:name).twice.and_return("FooBar::Baz")
        expect(subject.infer_model_name).to be(:baz)
      end

      it "returns :form when the class name is Form" do
        expect(subject).to receive(:name).twice.and_return("Form")
        expect(subject.infer_model_name).to be(:form)
      end

      it "strips the ending Form of the name when the class name ends with the Form suffix" do
        expect(subject).to receive(:name).twice.and_return("FooBar::BazForm")
        expect(subject.infer_model_name).to be(:baz)
      end
    end

    describe ".model_name" do
      subject { Class.new(described_class) }

      before do
        allow(subject).to receive(:name).and_return("FooBar::Baz")
      end

      it "returns an instance of ActiveModel::Name correctly initialized" do
        expect(subject.model_name).to be_a(ActiveModel::Name)
        expect(subject.model_name.singular).to eq("baz")
        expect(subject.model_name.plural).to eq("bazs")
      end
    end

    describe ".from_model" do
      subject { form.from_model(model) }

      let(:model) do
        OpenStruct.new(
          id: 1,
          name: "John",
          email: "john@example.org",
          boss: "0",
          drinks: [{ name: "Water" }],
          foods: { voner: { name: "Vöner", vegan: true } }
        )
      end

      it "initiates the form and the sub-form correctly" do
        expect(subject).to be_a(form)
        expect(subject.id).to eq(1)
        expect(subject.name).to eq("John")
        expect(subject.email).to eq("john@example.org")
        expect(subject.boss).to be(false)
        expect(subject.drinks.count).to eq(1)
        expect(subject.drinks[0].name).to eq("Water")
        expect(subject.foods.count).to eq(1)
        expect(subject.foods[:voner].name).to eq("Vöner")
        expect(subject.foods[:voner].vegan).to be(true)
        expect(subject.gadgets.empty?).to be(true)
      end

      context "when Active Record objects are provided as nested attribute values" do
        let(:drink_class) do
          Class.new(ApplicationRecord) do
            self.table_name = :decidim_dummy_resources_dummy_resources

            def custom_sauce
              "foobar"
            end
          end
        end
        let(:drink) { drink_class.new }

        let(:model) do
          OpenStruct.new(id: 1, drinks: [drink])
        end

        it "calls the map_model method on the created nested form object" do
          expect(subject.drinks.first.secret_sauce).to eq("foobar")
        end
      end
    end

    describe ".from_params" do
      subject { form.from_params(params) }

      let(:base_params) { valid_attributes.except(:gadgets).merge(boss: "1") }
      let(:params) { base_params }

      shared_examples "a valid record" do
        it "initiates the form and the sub-form correctly" do
          expect(subject).to be_a(form)
          expect(subject.id).to eq(1)
          expect(subject.name).to eq("John")
          expect(subject.email).to eq("john@example.org")
          expect(subject.boss).to be(true)
          expect(subject.drinks.count).to eq(3)
          expect(subject.drinks[0].name).to eq("Water")
          expect(subject.drinks[1].name).to eq("Cola")
          expect(subject.drinks[2].name).to eq("Beer")
          expect(subject.foods.count).to eq(2)
          expect(subject.foods[:meatballs].name).to eq("Meatballs")
          expect(subject.foods[:meatballs].vegan).to be(false)
          expect(subject.foods[:voner].name).to eq("Vöner")
          expect(subject.foods[:voner].vegan).to be(true)
          expect(subject.gadgets.empty?).to be(true)
        end
      end

      it_behaves_like "a valid record"

      context "when the parameters are provided through the mimicked model name" do
        let(:params) { { person: base_params } }

        it_behaves_like "a valid record"
      end

      context "when the parameters are provided as ActionController::Parameters" do
        let(:params) { ActionController::Parameters.new(base_params) }

        it_behaves_like "a valid record"
      end

      context "with additional params" do
        subject { form.from_params(params, additional) }

        let(:additional) { { name: "Joanna" } }

        it "overrides the base parameters with the additional parameters" do
          expect(subject.name).to eq("Joanna")
        end
      end
    end

    describe ".hash_from" do
      subject { described_class.hash_from(value) }

      let(:hash) { { foo: "bar", "baz" => "biz" } }

      shared_examples "a valid hash" do
        it "returns the hash with indifferent access" do
          expect(subject).to be_a(Hash)
          expect(subject[:foo]).to eq("bar")
          expect(subject["foo"]).to eq("bar")
          expect(subject[:baz]).to eq("biz")
          expect(subject["baz"]).to eq("biz")
        end
      end

      context "with a hash" do
        let(:value) { hash }

        it_behaves_like "a valid hash"
      end

      context "with ActionController::Parameters" do
        let(:value) { ActionController::Parameters.new(hash) }

        it_behaves_like "a valid hash"
      end
    end

    describe ".ensure_hash" do
      subject { described_class.ensure_hash(value) }

      context "when the value is not a hash" do
        let(:value) { double }

        it "returns an empty hash" do
          expect(subject).to eq({})
        end
      end

      context "when the value is a hash" do
        let(:value) { { foo: "bar" } }

        it "returns an empty hash" do
          expect(subject).to be(value)
        end
      end
    end

    describe "#persisted?" do
      context "when ID is not present" do
        let(:attributes) { {} }

        it "returns false" do
          expect(subject.persisted?).to be(false)
        end
      end

      context "when ID is present" do
        context "and zero" do
          let(:attributes) { { id: 0 } }

          it "returns false" do
            expect(subject.persisted?).to be(false)
          end
        end

        context "and negative" do
          let(:attributes) { { id: -1 } }

          it "returns false" do
            expect(subject.persisted?).to be(false)
          end
        end

        context "and positive" do
          let(:attributes) { { id: 1 } }

          it "returns true" do
            expect(subject.persisted?).to be(true)
          end
        end
      end
    end

    describe "#to_key" do
      it "converts the ID to an array" do
        expect(subject.to_key).to eq([1])
      end
    end

    describe "#to_model" do
      it "returns itself" do
        expect(subject.to_model).to be(subject)
      end
    end

    describe "#to_param" do
      it "converts the ID to string" do
        expect(subject.to_param).to eq("1")
      end
    end

    describe "#with_context" do
      let(:context) { { foo: "bar", baz: "biz" } }

      it "returns the model itself" do
        expect(subject.with_context(context)).to be(subject)
      end

      it "sets the correct context values" do
        subject.with_context(context)
        expect(subject.context).to be_a(OpenStruct)
        expect(subject.context.foo).to eq("bar")
        expect(subject.context.baz).to eq("biz")
      end
    end

    describe "#valid?" do
      context "with valid attributes" do
        it { is_expected.to be_valid }
      end

      context "when one of the attributes is not valid" do
        let(:attributes) { valid_attributes.except(:email) }

        it { is_expected.not_to be_valid }
      end

      context "when one of the sub-attributes is not valid" do
        let(:attributes) { valid_attributes.merge(drinks: [{ name: "Water" }, {}]) }

        it { is_expected.not_to be_valid }
      end

      context "when one of the extending sub-attributes is not valid" do
        let(:attributes) { valid_attributes.merge(foods: { meatballs: { name: "Meatballs" }, voner: { vegan: true } }) }

        it { is_expected.not_to be_valid }
      end

      context "when one of the unspecified attribute types is a Decidim::AttributeObject::Model" do
        let(:attributes) { valid_attributes.merge(any: subrecord) }
        let(:subklass) do
          Class.new do
            include Decidim::AttributeObject::Model
            include ActiveModel::Validations

            attribute :foo, String

            def self.model_name
              ActiveModel::Name.new(self, nil, "Sub")
            end
          end
        end
        let(:subrecord) { subklass.new(subattributes) }
        let(:subattributes) { { foo: "bar" } }

        context "when the attribute is valid" do
          it { is_expected.to be_valid }
        end

        context "when the attribute is not valid" do
          before do
            # Manually add an error to the sub-record
            subrecord.errors.add(:foo, :invalid)
          end

          it { is_expected.not_to be_valid }
        end
      end

      context "when one of the unspecified attribute types is a Decidim::AttributeObject::Form" do
        let(:attributes) { valid_attributes.merge(any: subrecord) }
        let(:subklass) do
          Class.new(Decidim::AttributeObject::Form) do
            attribute :foo, String

            validates :foo, presence: true
          end
        end
        let(:subrecord) { subklass.new(subattributes) }

        before do
          # Run the validations so that the errors are added to the subrecord
          subrecord.valid?
        end

        context "when the attribute is valid" do
          let(:subattributes) { { foo: "bar" } }

          it { is_expected.to be_valid }
        end

        context "when the attribute is not valid" do
          let(:subattributes) { {} }

          it { is_expected.not_to be_valid }
        end
      end

      context "when one of the ActiveModel records is not valid" do
        before do
          subject.gadgets[1].brand = nil
        end

        # It is correct that the ActiveModel or ActiveRecord records should not
        # be checked against their validations.
        it "does not care if these records are invalid" do
          expect(subject.gadgets[1].valid?).to be(false)

          expect(subject).to be_valid
        end
      end
    end
  end
end
