# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AttributeEncryptor do
    describe ".decrypt" do
      context "when the passed value is blank" do
        let(:value) { "" }

        it "returns nil" do
          expect(described_class.decrypt(value)).to eq(nil)
        end
      end

      context "when the passed value is a hash" do
        let(:value) { { "foo" => "bar" } }

        it "returns the original value" do
          expect(described_class.decrypt(value)).to eq(value)
        end
      end

      context "when the passed value is an Integer" do
        let(:value) { 123 }

        it "returns the original value" do
          expect(described_class.decrypt(value)).to eq(123)
        end
      end

      context "when the passed value is an a test double" do
        let(:value) { double }

        it "returns the original value" do
          expect(described_class.decrypt(value)).to be(value)
        end
      end
    end
  end
end
