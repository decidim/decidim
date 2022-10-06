# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Gamification do
    let!(:user) { create(:user) }

    describe "#status_for" do
      it "returns the status of a user for a badge" do
        Gamification::BadgeScore.create(user:, value: 2, badge_name: "test")
        expect(Gamification.status_for(user, :test).score).to eq(2)
      end
    end

    describe "#reset_badges" do
      it "resets all badges to their original status" do
        Gamification.reset_badges(User.where(id: user.id))
        expect(Gamification.status_for(user, :test).score).to eq(100)
      end
    end

    describe "#increment_score" do
      it "increments a user's score for a badge by 1" do
        Gamification.increment_score(user, :test)
        expect(Gamification.status_for(user, :test).score).to eq(1)
      end
    end

    describe "#set_score" do
      it "sets the score of a user to a particular value" do
        Gamification.set_score(user, :test, 10)
        expect(Gamification.status_for(user, :test).score).to eq(10)
      end
    end

    describe "#find_badge" do
      it "returns a badge given its name" do
        badge = Gamification.find_badge(:test)
        expect(badge.name).to eq("test")
        expect(badge.levels).to eq([1, 5, 10])
      end
    end

    describe "#badges" do
      it "returns all the available badges" do
        badge = Gamification.find_badge(:test)
        expect(Gamification.badges).to include(badge)
      end
    end
  end
end
