# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AttributeObject::NestedValidator do
    subject { validatable.new(nested:) }

    let(:validatable) do
      Class.new do
        def self.model_name
          ActiveModel::Name.new(self, nil, "Validatable")
        end

        include Decidim::AttributeObject::Model
        include ActiveModel::Validations

        attribute :nested

        validates_with Decidim::AttributeObject::NestedValidator, attributes: [:nested]
      end
    end
    let(:nested) { double }

    context "with an object that does not respond to #valid?" do
      it { is_expected.to be_valid }
    end

    context "with an object that responds to #valid?" do
      let(:nested) { double(valid?: validity) }
      let(:validity) { true }

      it { is_expected.to be_valid }

      context "when the object is not valid" do
        let(:validity) { false }

        it { is_expected.not_to be_valid }
      end
    end

    context "with an array of objects that do not respond to #valid?" do
      let(:nested) { [double, double] }

      it { is_expected.to be_valid }
    end

    context "with an array of objects that respond to #valid?" do
      let(:nested) { [value1, value2] }
      let(:value1) { double(valid?: true) }
      let(:value2) { double(valid?: true) }

      it { is_expected.to be_valid }

      context "when one of the objects is not valid" do
        let(:value2) { double(valid?: false) }

        it { is_expected.not_to be_valid }
      end
    end

    context "with a value hash of objects that do not respond to #valid?" do
      let(:nested) { { foo: double, bar: double } }

      it { is_expected.to be_valid }
    end

    context "with a value hash of objects that respond to #valid?" do
      let(:nested) { { foo: value1, bar: value2 } }
      let(:value1) { double(valid?: true) }
      let(:value2) { double(valid?: true) }

      it { is_expected.to be_valid }

      context "when one of the objects is not valid" do
        let(:value2) { double(valid?: false) }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
