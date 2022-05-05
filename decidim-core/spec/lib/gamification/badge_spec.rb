# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Gamification
    describe Badge do
      context "with all the required fields" do
        it "is valid" do
          badge = described_class.new
          badge.name = :test
          badge.levels = [1, 5, 10]
          expect(badge).to be_valid
          expect(badge.errors).to be_empty
        end
      end

      context "without a name" do
        it "isn't valid" do
          badge = described_class.new
          badge.name = nil
          badge.valid?
          expect(badge.errors[:name]).not_to be_empty
        end
      end

      describe "levels" do
        context "with an empty array" do
          it "doesn't validate" do
            badge = described_class.new
            badge.levels = []
            badge.valid?
            expect(badge.errors[:levels]).not_to be_empty
          end
        end

        context "with negative values" do
          it "doesn't validate" do
            badge = described_class.new
            badge.levels = [-1, 5, 10]
            badge.valid?
            expect(badge.errors[:levels]).not_to be_empty
          end
        end

        context "with unordered values" do
          it "doesn't validate" do
            badge = described_class.new
            badge.levels = [1, 10, 5]
            badge.valid?
            expect(badge.errors[:levels]).not_to be_empty
          end
        end

        context "with repeated values" do
          it "doesn't validate" do
            badge = described_class.new
            badge.levels = [1, 10, 10, 20]
            badge.valid?
            expect(badge.errors[:levels]).not_to be_empty
          end
        end

        describe "#level_of" do
          let(:badge) { described_class.new(levels: [1, 5, 10], name: "test") }

          it "returns 0 if the score is 0" do
            expect(badge.level_of(0)).to eq(0)
          end

          it "returns the first level when the threshold matches the first level" do
            expect(badge.level_of(1)).to eq(1)
          end

          it "returns a level when the threshold matches that level" do
            expect(badge.level_of(5)).to eq(2)
          end

          it "returns the level when the score exceeds the last level" do
            expect(badge.level_of(100)).to eq(3)
          end
        end
      end
    end
  end
end
