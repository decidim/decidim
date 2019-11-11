# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Gamification do
    let!(:user) { create(:user) }

    describe "#status_for" do
      it "returns the status of a user for a badge" do
        Gamification::BadgeScore.create(user: user, value: 2, badge_name: "test")
        expect(described_class.status_for(user, :test).score).to eq(2)
      end
    end

    describe "#reset_badges" do
      it "resets all badges to their original status" do
        described_class.reset_badges(User.where(id: user.id))
        expect(described_class.status_for(user, :test).score).to eq(100)
      end
    end

    describe "#increment_score" do
      it "increments a user's score for a badge by 1" do
        described_class.increment_score(user, :test)
        expect(described_class.status_for(user, :test).score).to eq(1)
      end
    end

    describe "#set_score" do
      it "sets the score of a user to a particular value" do
        described_class.set_score(user, :test, 10)
        expect(described_class.status_for(user, :test).score).to eq(10)
      end
    end

    describe "#find_badge" do
      it "returns a badge given its name" do
        badge = described_class.find_badge(:test)
        expect(badge.name).to eq("test")
        expect(badge.levels).to eq([1, 5, 10])
      end
    end

    describe "#badges" do
      it "returns all the available badges" do
        badge = described_class.find_badge(:test)
        expect(described_class.badges).to include(badge)
      end
    end
  end
end
