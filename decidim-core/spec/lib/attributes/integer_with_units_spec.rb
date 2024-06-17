# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Attributes::IntegerWithUnits do
    describe "#cast" do
      subject { described_class.new.cast(value) }

      context "when given a String" do
        let(:value) { "1" }

        it "returns the integer" do
          expect(subject).to eq(1)
        end
      end

      context "when given an Array" do
        let(:value) { %w(1 minutes) }

        it "returns the integer and the unit" do
          expect(subject).to eq([1, "minutes"])
        end
      end
    end
  end
end
