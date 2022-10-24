# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Attributes::Hash do
    subject { type }

    let(:type) { described_class.new(key_type:, value_type:, default:) }
    let(:key_type) { ::Symbol }
    let(:value_type) { ::Object }
    let(:default) { {} }

    describe "#type" do
      it "returns :hash" do
        expect(subject.type).to be(:hash)
      end
    end

    describe "#key_type" do
      let(:key_type) { double }

      it "returns the defined key type" do
        expect(type.key_type).to be(key_type)
      end
    end

    describe "#value_type" do
      let(:value_type) { double }

      it "returns the defined value type" do
        expect(type.value_type).to be(value_type)
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
        expect(subject).to eq({})
      end

      it "does not allow editing the returned default value" do
        subject[:foo] = "bar"

        expect(type.default).to eq({})
      end

      context "with custom default value" do
        let(:default) { { foo: "bar", baz: "biz" } }

        it "returns the default value for the provided nil value" do
          expect(subject).to eq(foo: "bar", baz: "biz")
        end

        it "does not return the same instance of the default value" do
          expect(subject).not_to be(default)
        end
      end

      context "with correct key types" do
        let(:value) { { foo: "bar", baz: "biz" } }

        it "returns the correct key types" do
          expect(subject).to eq(foo: "bar", baz: "biz")
        end
      end

      context "with incorrect key types" do
        let(:value) { { "foo" => "bar", "baz" => "biz" } }

        it "converts the correct key types" do
          expect(subject).to eq(foo: "bar", baz: "biz")
        end
      end

      context "with correct value types" do
        let(:value) { { foo: :bar, baz: :biz } }
        let(:value_type) { ::Symbol }

        it "returns the correct value types" do
          expect(subject).to eq(foo: :bar, baz: :biz)
        end
      end

      context "with incorrect value types" do
        let(:value) { { foo: "bar", baz: "biz" } }
        let(:value_type) { ::Symbol }

        it "converts the correct value types" do
          expect(subject).to eq(foo: :bar, baz: :biz)
        end
      end

      context "with an object responding to to_h" do
        let(:value) { double }
        let(:converted_value) { { foo: "bar", baz: "biz" } }

        before do
          allow(value).to receive(:to_h).and_return(converted_value)
        end

        it "returns the value returned by the to_h method" do
          expect(subject).to eq(converted_value)
        end
      end

      context "with a non-hash value that does not respond to to_h" do
        let(:value) { double }

        it "returns the value itself" do
          expect(subject).to be(value)
        end
      end
    end
  end
end
