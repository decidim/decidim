# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NotificationsSettingsForm do
    subject do
      described_class.from_params(
        notifications_from_followed: notifications_from_followed,
        notifications_from_own_activity: notifications_from_own_activity,
        notifications_sending_frequency: notifications_sending_frequency,
        email_on_moderations: email_on_moderations,
        newsletter_notifications: newsletter_notifications,
        allow_public_contact: allow_public_contact
      ).with_context(
        current_user: user
      )
    end

    let(:user) { create(:user) }

    let(:notifications_from_followed) { "1" }
    let(:notifications_from_own_activity) { "1" }
    let(:email_on_moderations) { "1" }
    let(:newsletter_notifications) { "1" }
    let(:allow_public_contact) { "1" }
    let(:notifications_sending_frequency) { "real_time" }

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

    describe "direct_message_types" do
      context "when allow_public_contact is present" do
        it "returns all" do
          expect(subject.direct_message_types).to eq "all"
        end
      end

      context "when allow_public_contact is blank" do
        let(:allow_public_contact) { "0" }

        it "returns followed-only" do
          expect(subject.direct_message_types).to eq "followed-only"
        end
      end
    end

    describe "map model" do
      subject { described_class.from_model(user) }

      context "with notification_types all" do
        let(:user) { create :user, notification_types: :all }

        it "maps the fields correctly" do
          expect(subject.notifications_from_followed).to be true
          expect(subject.notifications_from_own_activity).to be true
        end
      end

      context "with notification_types followed-only" do
        let(:user) { create :user, notification_types: "followed-only" }

        it "maps the fields correctly" do
          expect(subject.notifications_from_followed).to be true
          expect(subject.notifications_from_own_activity).to be false
        end
      end

      context "with notification_types own-only" do
        let(:user) { create :user, notification_types: "own-only" }

        it "maps the fields correctly" do
          expect(subject.notifications_from_followed).to be false
          expect(subject.notifications_from_own_activity).to be true
        end
      end

      context "with notification_types none" do
        let(:user) { create :user, notification_types: :none }

        it "maps the fields correctly" do
          expect(subject.notifications_from_followed).to be false
          expect(subject.notifications_from_own_activity).to be false
        end
      end

      context "with newsletter_notifications_at present" do
        let(:user) { create :user, newsletter_notifications_at: Time.current }

        it "maps the fields correctly" do
          expect(subject.newsletter_notifications).to be true
        end
      end

      context "with newsletter_notifications_at blank" do
        let(:user) { create :user, newsletter_notifications_at: nil }

        it "maps the fields correctly" do
          expect(subject.newsletter_notifications).to be false
        end
      end

      context "with allow_public_contact present" do
        let(:user) { create :user, direct_message_types: "all" }

        it "maps the fields correctly" do
          expect(subject.allow_public_contact).to be true
        end
      end

      context "with allow_public_contact blank" do
        let(:user) { create :user, direct_message_types: "followed-only" }

        it "maps the fields correctly" do
          expect(subject.allow_public_contact).to be false
        end
      end

      context "with notifications_sending_frequency present" do
        let(:user) { create :user, notifications_sending_frequency: "real_time" }

        it "maps the fields correctly" do
          expect(subject.notifications_sending_frequency).to eq "real_time"
        end
      end
    end

    describe "#user_is_moderator?" do
      context "when an organization has a moderator and a regular user" do
        let(:organization) { create :organization, available_locales: [:en] }
        let(:participatory_space) { create :participatory_process, organization: organization }
        let(:moderator) do
          create(
            :process_moderator,
            :confirmed,
            organization: organization,
            participatory_process: participatory_space
          )
        end
        let(:user) { create :user, organization: organization }

        it "returns false when user isnt a moderator" do
          expect(subject.user_is_moderator?(user)).to be false
        end

        it "returns true when user is a moderator" do
          expect(subject.user_is_moderator?(moderator)).to be true
        end
      end
    end

    describe "#meet_push_notifications_requirements?" do
      context "when the notifications requirements are met" do
        before do
          allow(Rails.application.secrets).to receive("vapid").and_return({ enabled: true })
        end

        it "returns true" do
          expect(subject.meet_push_notifications_requirements?).to be true
        end
      end

      context "when the notifications requirements aren't met" do
        before do
          allow(Rails.application.secrets).to receive("vapid").and_return({ enabled: false })
        end

        it "returns false" do
          expect(subject.meet_push_notifications_requirements?).to be false
        end
      end
    end
  end
end
