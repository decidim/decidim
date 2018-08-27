# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Gamification
    describe BadgeScorer do
      subject { described_class.new(user, badge) }

      let(:user) { create(:user) }
      let(:badge) { Badge.new(name: "test", levels: [1, 3, 5]) }

      describe "#increment" do
        context "when there's no previous score" do
          it "sets the score to 1" do
            subject.increment
            status = BadgeStatus.new(user, badge)
            expect(status.score).to eq(1)
          end
        end

        context "when there's a previous score" do
          before do
            BadgeScore.create(user: user, badge_name: badge.name, value: 10)
          end

          it "increments the score by 1 by default" do
            subject.increment
            status = BadgeStatus.new(user, badge)
            expect(status.score).to eq(11)
          end

          it "increments the score by the provided amount" do
            subject.increment(10)
            status = BadgeStatus.new(user, badge)
            expect(status.score).to eq(20)
          end
        end
      end

      describe "#set" do
        context "when there's no previous score" do
          it "sets the score to the provided value" do
            subject.set(10)
            status = BadgeStatus.new(user, badge)
            expect(status.score).to eq(10)
          end
        end

        context "when there's a previous score" do
          before do
            BadgeScore.create(user: user, badge_name: badge.name, value: 10)
          end

          it "sets the score to the provided value" do
            subject.set(5)
            status = BadgeStatus.new(user, badge)
            expect(status.score).to eq(5)
          end
        end
      end

      describe "notifications" do
        describe "badge earned notification" do
          it "sends a notification when earning a new badge" do
            expect(Decidim::EventsManager).to receive(:publish).with(
              hash_including(
                event: "decidim.events.gamification.badge_earned",
                event_class: BadgeEarnedEvent,
                resource: user,
                recipient_ids: [user.id],
                extra: {
                  badge_name: "test",
                  previous_level: 0,
                  current_level: 1
                }
              )
            )
            subject.increment
          end
        end

        describe "new level notification" do
          it "sends a notification when reaching a new level" do
            expect(Decidim::EventsManager).to receive(:publish).with(
              hash_including(
                event: "decidim.events.gamification.level_up",
                event_class: LevelUpEvent,
                resource: user,
                recipient_ids: [user.id],
                extra: {
                  badge_name: "test",
                  previous_level: 1,
                  current_level: 2
                }
              )
            )
            BadgeScore.create(user: user, badge_name: badge.name, value: 2)
            subject.increment
          end
        end
      end
    end
  end
end
