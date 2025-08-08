# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Attributes::IntegerWithUnits do
    describe "#cast" do
      subject { described_class.new.cast(value) }

      describe "#cast" do
        context "when given nil" do
          let(:value) { nil }

          it "returns nil" do
            expect(subject).to be_nil
          end
        end

        context "when given a Hash" do
          let(:value) { { "0" => "5", "1" => "minutes" } }

          it "returns an array with the integer and the unit" do
            expect(subject).to eq([5, "minutes"])
          end

          context "when the integer is negative" do
            let(:value) { { "0" => "-5", "1" => "minutes" } }

            it "returns an array with the absolute value of the integer and the unit" do
              expect(subject).to eq([5, "minutes"])
            end
          end
        end

        context "when given an Array" do
          let(:value) { %w(5 minutes) }

          it "returns an array with the integer and the unit" do
            expect(subject).to eq([5, "minutes"])
          end

          context "when the array size is not 2" do
            let(:value) { ["5"] }

            it "returns the original value" do
              expect(subject).to eq(["5"])
            end
          end

          context "when the integer is negative" do
            let(:value) { %w(-5 minutes) }

            it "returns an array with the absolute value of the integer and the unit" do
              expect(subject).to eq([5, "minutes"])
            end
          end
        end

        context "when given other values" do
          let(:value) { "some string" }

          it "returns the original value" do
            expect(subject).to eq("some string")
          end
        end
      end
    end
  end
end
