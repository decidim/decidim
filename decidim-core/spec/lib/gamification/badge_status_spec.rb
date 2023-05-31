# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Gamification
    describe BadgeStatus do
      subject { described_class.new(user, badge) }

      let(:user) { create(:user) }
      let(:badge) { Badge.new(name: "test", levels: [1, 2, 10, 50]) }

      describe "#score" do
        it "returns 0 when no score is stored" do
          expect(subject.score).to eq(0)
        end

        it "returns the stored value when stored in the database" do
          BadgeScore.create(user:, badge_name: "test", value: 3)
          expect(subject.score).to eq(3)
        end
      end

      describe "#level" do
        it "returns the level of a user" do
          BadgeScore.create(user:, badge_name: "test", value: 3)
          expect(subject.level).to eq(2)
        end
      end

      describe "#next_level_in" do
        it "returns the score remaining to the next level of a user" do
          BadgeScore.create(user:, badge_name: "test", value: 3)
          expect(subject.next_level_in).to eq(7)
        end
      end
    end
  end
end
