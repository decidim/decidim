# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NotificationsSettingsForm do
    subject do
      described_class.from_params(
        notifications_from_followed: notifications_from_followed,
        notifications_from_own_activity: notifications_from_own_activity,
        email_on_notification: email_on_notification,
        newsletter_notifications: newsletter_notifications
      ).with_context(
        current_user: user
      )
    end

    let(:user) { create(:user) }

    let(:notifications_from_followed) { "1" }
    let(:notifications_from_own_activity) { "1" }
    let(:email_on_notification) { "1" }
    let(:newsletter_notifications) { "1" }

    context "with correct data" do
      it "is valid" do
        expect(subject).to be_valid
      end
    end

    describe "notification_types" do
      context "when both are present" do
        it "returns all" do
          expect(subject.notification_types).to eq "all"
        end
      end

      context "when only followed is present" do
        let(:notifications_from_own_activity) { "0" }

        it "returns all" do
          expect(subject.notification_types).to eq "followed-only"
        end
      end

      context "when only own is present" do
        let(:notifications_from_followed) { "0" }

        it "returns all" do
          expect(subject.notification_types).to eq "own-only"
        end
      end

      context "when none is present" do
        let(:notifications_from_followed) { "0" }
        let(:notifications_from_own_activity) { "0" }

        it "returns all" do
          expect(subject.notification_types).to eq "none"
        end
      end
    end

    describe "map model" do
      subject { described_class.from_model(user) }

      context "with notification_types all" do
        let(:user) { create :user, notification_types: :all }

        it "maps the fields correctly" do
          expect(subject.notifications_from_followed).to eq true
          expect(subject.notifications_from_own_activity).to eq true
        end
      end

      context "with notification_types followed-only" do
        let(:user) { create :user, notification_types: "followed-only" }

        it "maps the fields correctly" do
          expect(subject.notifications_from_followed).to eq true
          expect(subject.notifications_from_own_activity).to eq false
        end
      end

      context "with notification_types own-only" do
        let(:user) { create :user, notification_types: "own-only" }

        it "maps the fields correctly" do
          expect(subject.notifications_from_followed).to eq false
          expect(subject.notifications_from_own_activity).to eq true
        end
      end

      context "with notification_types none" do
        let(:user) { create :user, notification_types: :none }

        it "maps the fields correctly" do
          expect(subject.notifications_from_followed).to eq false
          expect(subject.notifications_from_own_activity).to eq false
        end
      end

      context "with newsletter_notifications_at present" do
        let(:user) { create :user, newsletter_notifications_at: Time.current }

        it "maps the fields correctly" do
          expect(subject.newsletter_notifications).to eq true
        end
      end

      context "with newsletter_notifications_at blank" do
        let(:user) { create :user, newsletter_notifications_at: nil }

        it "maps the fields correctly" do
          expect(subject.newsletter_notifications).to eq false
        end
      end
    end
  end
end
