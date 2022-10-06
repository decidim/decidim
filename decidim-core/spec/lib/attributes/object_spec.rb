# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Attributes::Object do
    subject { type }

    let(:type) { described_class.new(primitive:) }
    let(:primitive) { ::Object }

    describe "#type" do
      it "returns :object" do
        expect(subject.type).to be(:object)
      end
    end

    describe "#primitive" do
      let(:primitive) { double }

      it "returns the defined primitive type" do
        expect(type.primitive).to be(primitive)
      end
    end

    describe "#validate_nested?" do
      let(:primitive) { double }

      it "returns false for non-object type primitives" do
        expect(subject.validate_nested?).to be(false)
      end

      context "when a module primitive is provided" do
        let(:primitive) { Decidim::AttributeObject::Model }

        it "returns false because it is not a class" do
          expect(subject.validate_nested?).to be(false)
        end
      end

      context "when a class primitive is provided" do
        context "with a class that implements Decidim::AttributeObject::Model" do
          let(:primitive) { Class.new { include Decidim::AttributeObject::Model } }

          it "returns true" do
            expect(subject.validate_nested?).to be(true)
          end
        end

        context "without a class that implements Decidim::AttributeObject::Model" do
          let(:primitive) { Class.new }

          it "returns false" do
            expect(subject.validate_nested?).to be(false)
          end
        end
      end
    end

    describe "#cast" do
      subject { type.cast(value) }

      let(:value) { double }

      it "returns the value itself" do
        expect(subject).to be(value)
      end
    end
  end
end
