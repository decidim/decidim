# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Attributes::Symbol do
    describe "#type" do
      it "returns :symbol" do
        expect(subject.type).to be(:symbol)
      end
    end

    describe "#cast" do
      subject { described_class.new.cast(value) }

      context "with a string value" do
        let(:value) { "foo" }

        it "returns the value cast to symbol" do
          expect(subject).to be(:foo)
        end
      end

      context "with a constant value" do
        let(:value) { OpenStruct }

        it "returns the value cast to string and then to symbol" do
          expect(subject).to be(:OpenStruct)
        end
      end

      context "with a value that cannot be converted to string or to symbol" do
        let(:value) { double }

        before do
          allow(value).to receive(:respond_to?).with(:to_sym).and_return(false)
          allow(value).to receive(:respond_to?).with(:to_s).and_return(false)
        end

        it "returns nil" do
          expect(subject).to be_nil
        end
      end
    end
  end
end
