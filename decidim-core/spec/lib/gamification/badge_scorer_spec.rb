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

        context "when provided a negative value" do
          it "raises an exception" do
            expect { subject.increment(-1) }.to raise_exception(Decidim::Gamification::BadgeScorer::InvalidAmountException)
            status = BadgeStatus.new(user, badge)
            expect(status.score).to eq(0)
          end
        end

        context "when there's a previous score" do
          before do
            BadgeScore.create(user:, badge_name: badge.name, value: 10)
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

      describe "#decrement" do
        context "when there's no previous score" do
          it "doesn't do anything" do
            subject.decrement
            status = BadgeStatus.new(user, badge)
            expect(status.score).to eq(0)
          end
        end

        context "when provided a negative value" do
          it "raises an exception" do
            expect { subject.decrement(-1) }.to raise_exception(Decidim::Gamification::BadgeScorer::InvalidAmountException)
            status = BadgeStatus.new(user, badge)
            expect(status.score).to eq(0)
          end
        end

        context "when there's a previous score" do
          before do
            BadgeScore.create(user:, badge_name: badge.name, value: 10)
          end

          it "decrements the score by 1 by default" do
            subject.decrement
            status = BadgeStatus.new(user, badge)
            expect(status.score).to eq(9)
          end

          it "decrements the score by the provided amount" do
            subject.decrement(6)
            status = BadgeStatus.new(user, badge)
            expect(status.score).to eq(4)
          end

          it "sets the score to 0 if decrementing below 0" do
            subject.decrement(11)
            status = BadgeStatus.new(user, badge)
            expect(status.score).to eq(0)
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
            BadgeScore.create(user:, badge_name: badge.name, value: 10)
          end

          it "sets the score to the provided value" do
            subject.set(5)
            status = BadgeStatus.new(user, badge)
            expect(status.score).to eq(5)
          end
        end

        context "when a negative value is provided" do
          it "raises an exception" do
            expect do
              subject.set(-5)
            end.to raise_exception(Decidim::Gamification::BadgeScorer::NegativeScoreException)

            status = BadgeStatus.new(user, badge)
            expect(status.score).to eq(0)
          end
        end
      end

      describe "notifications" do
        describe "badge earned notification" do
          context "when badges are enabled organization-wide" do
            before do
              user.organization.update(badges_enabled: true)
            end

            it "sends a notification when earning a new badge" do
              expect(Decidim::EventsManager).to receive(:publish).with(
                hash_including(
                  event: "decidim.events.gamification.badge_earned",
                  event_class: BadgeEarnedEvent,
                  resource: user,
                  affected_users: [user],
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

          context "when badges are disabled organization-wide" do
            before do
              user.organization.update(badges_enabled: false)
            end

            it "doesn't send a notification" do
              expect(Decidim::EventsManager).not_to receive(:publish).with(anything)
              subject.increment
            end
          end
        end

        describe "new level notification" do
          it "sends a notification when reaching a new level" do
            expect(Decidim::EventsManager).to receive(:publish).with(
              hash_including(
                event: "decidim.events.gamification.level_up",
                event_class: LevelUpEvent,
                resource: user,
                affected_users: [user],
                extra: {
                  badge_name: "test",
                  previous_level: 1,
                  current_level: 2
                }
              )
            )
            BadgeScore.create(user:, badge_name: badge.name, value: 2)
            subject.increment
          end
        end
      end
    end
  end
end
