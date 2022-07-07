# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Attributes::Array do
    subject { type }

    let(:type) { described_class.new(value_type: value_type, default: default) }
    let(:value_type) { ::Object }
    let(:default) { [] }

    describe "#type" do
      it "returns :array" do
        expect(subject.type).to be(:array)
      end
    end

    describe "#value_type" do
      let(:value_type) { double }

      it "returns the defined value type" do
        expect(type.value_type).to be(value_type)
      end
    end

    describe "#validate_nested?" do
      let(:value_type) { double }

      it "returns false for non-object type values" do
        expect(subject.validate_nested?).to be(false)
      end

      context "when a module value type is provided" do
        let(:value_type) { Decidim::AttributeObject::Model }

        it "returns false because it is not a class" do
          expect(subject.validate_nested?).to be(false)
        end
      end

      context "when a class value type is provided" do
        context "with a class that implements Decidim::AttributeObject::Model" do
          let(:value_type) { Class.new { include Decidim::AttributeObject::Model } }

          it "returns true" do
            expect(subject.validate_nested?).to be(true)
          end
        end

        context "without a class that implements Decidim::AttributeObject::Model" do
          let(:value_type) { Class.new }

          it "returns false" do
            expect(subject.validate_nested?).to be(false)
          end
        end
      end
    end

    describe "#default" do
      let(:default) { double }

      it "returns the default value" do
        expect(type.default).to be(default)
      end
    end

    describe "#cast" do
      subject { type.cast(value) }

      let(:value) { nil }

      it "returns the default value for the provided nil value" do
        expect(subject).to eq([])
      end

      it "does not allow editing the returned default value" do
        subject << "foo"

        expect(type.default).to eq([])
      end

      context "with custom default value" do
        let(:default) { %w(foo bar) }

        it "returns the default value for the provided nil value" do
          expect(subject).to eq(%w(foo bar))
        end

        it "does not return the same instance of the default value" do
          expect(subject).not_to be(default)
        end
      end

      context "with correct value types" do
        let(:value) { [:foo, :bar] }
        let(:value_type) { ::Symbol }

        it "returns the correct value types" do
          expect(subject).to eq([:foo, :bar])
        end
      end

      context "with incorrect value types" do
        let(:value) { %w(foo bar) }
        let(:value_type) { ::Symbol }

        it "converts the correct value types" do
          expect(subject).to eq([:foo, :bar])
        end
      end

      context "with an object responding to to_a" do
        let(:value) { double }
        let(:converted_value) { %w(foo bar) }

        before do
          allow(value).to receive(:to_a).and_return(converted_value)
        end

        it "returns the value returned by the to_a method" do
          expect(subject).to eq(converted_value)
        end
      end

      context "with an object not responding to_a" do
        let(:value) { "foo" }

        it "returns the value wrapped in an array" do
          expect(subject).to eq(%w(foo))
        end
      end

      context "with a hash value" do
        let(:value) { { a: "foo", b: "bar" } }

        it "returns values of the hash" do
          expect(subject).to eq(%w(foo bar))
        end
      end
    end
  end
end
