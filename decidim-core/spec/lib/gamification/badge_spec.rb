# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Gamification
    describe Badge do
      let(:badge) { described_class.new(name: "followers", levels: [1, 5, 10, 30, 50]) }

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
        it "is not valid" do
          badge = described_class.new
          badge.name = nil
          badge.valid?
          expect(badge.errors[:name]).not_to be_empty
        end
      end

      describe "levels" do
        context "with an empty array" do
          it "does not validate" do
            badge = described_class.new
            badge.levels = []
            badge.valid?
            expect(badge.errors[:levels]).not_to be_empty
          end
        end

        context "with negative values" do
          it "does not validate" do
            badge = described_class.new
            badge.levels = [-1, 5, 10]
            badge.valid?
            expect(badge.errors[:levels]).not_to be_empty
          end
        end

        context "with unordered values" do
          it "does not validate" do
            badge = described_class.new
            badge.levels = [1, 10, 5]
            badge.valid?
            expect(badge.errors[:levels]).not_to be_empty
          end
        end

        context "with repeated values" do
          it "does not validate" do
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

      describe "#translated_name" do
        subject { badge.translated_name }

        it { is_expected.to eq("Followers") }
      end

      describe "#description" do
        subject { badge.description }

        it { is_expected.to eq("This badge is granted when you reach a certain number of followers.  is a social and political network, weave your web to communicate with other people in the platform.") }
      end

      describe "#conditions" do
        subject { badge.conditions }

        it { is_expected.to eq(["Being active and following other people will surely make other people follow you."]) }
      end

      describe "#score_descriptions" do
        subject { badge.score_descriptions(1) }

        it "returns the correct descriptions" do
          expect(subject).to eq(
            {
              description_another: "This participant has 1 followers.",
              description_own: "1 people are following you.",
              unearned_another: "This participant does not have any followers yet.",
              unearned_own: "You have got no followers yet."
            }
          )
        end
      end

      describe "#image" do
        subject { badge.image }

        it { is_expected.to match(%r{/packs-test/media/images/decidim_gamification_badges_followers-[0-9a-f]+.svg}) }
      end
    end
  end
end
