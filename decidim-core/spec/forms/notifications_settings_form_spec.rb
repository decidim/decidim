# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NotificationsSettingsForm do
    subject do
      described_class.from_params(
        notifications_from_followed:,
        notifications_from_own_activity:,
        notifications_sending_frequency:,
        email_on_moderations:,
        email_on_assigned_proposals:,
        newsletter_notifications:,
        allow_public_contact:
      ).with_context(
        current_user: user
      )
    end

    let(:user) { create(:user) }

    let(:notifications_from_followed) { "1" }
    let(:notifications_from_own_activity) { "1" }
    let(:email_on_moderations) { "1" }
    let(:email_on_assigned_proposals) { "1" }
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
        let(:user) { create(:user, notification_types: :all) }

        it "maps the fields correctly" do
          expect(subject.notifications_from_followed).to be true
          expect(subject.notifications_from_own_activity).to be true
        end
      end

      context "with notification_types followed-only" do
        let(:user) { create(:user, notification_types: "followed-only") }

        it "maps the fields correctly" do
          expect(subject.notifications_from_followed).to be true
          expect(subject.notifications_from_own_activity).to be false
        end
      end

      context "with notification_types own-only" do
        let(:user) { create(:user, notification_types: "own-only") }

        it "maps the fields correctly" do
          expect(subject.notifications_from_followed).to be false
          expect(subject.notifications_from_own_activity).to be true
        end
      end

      context "with notification_types none" do
        let(:user) { create(:user, notification_types: :none) }

        it "maps the fields correctly" do
          expect(subject.notifications_from_followed).to be false
          expect(subject.notifications_from_own_activity).to be false
        end
      end

      context "with newsletter_notifications_at present" do
        let(:user) { create(:user, newsletter_notifications_at: Time.current) }

        it "maps the fields correctly" do
          expect(subject.newsletter_notifications).to be true
        end
      end

      context "with newsletter_notifications_at blank" do
        let(:user) { create(:user, newsletter_notifications_at: nil) }

        it "maps the fields correctly" do
          expect(subject.newsletter_notifications).to be false
        end
      end

      context "with allow_public_contact present" do
        let(:user) { create(:user, direct_message_types: "all") }

        it "maps the fields correctly" do
          expect(subject.allow_public_contact).to be true
        end
      end

      context "with allow_public_contact blank" do
        let(:user) { create(:user, direct_message_types: "followed-only") }

        it "maps the fields correctly" do
          expect(subject.allow_public_contact).to be false
        end
      end

      context "with notifications_sending_frequency present" do
        let(:user) { create(:user, notifications_sending_frequency: "real_time") }

        it "maps the fields correctly" do
          expect(subject.notifications_sending_frequency).to eq "real_time"
        end
      end
    end

    describe "#newsletter_notifications_at" do
      let(:current_time) { Time.current }

      it { expect(subject.newsletter_notifications_at).to be_between(current_time - 1.minute, current_time + 1.minute) }

      context "when the newsletter notifications were not ordered" do
        let(:newsletter_notifications) { "0" }

        it { expect(subject.newsletter_notifications_at).to be_nil }
      end
    end

    describe "#meet_push_notifications_requirements?" do
      context "when the notifications requirements are met" do
        before do
          allow(Decidim).to receive(:vapid_public_key).and_return("FOO BAR")
        end

        it "returns true" do
          expect(subject.meet_push_notifications_requirements?).to be true
        end
      end

      context "when vapid secrets are not present" do
        before do
          allow(Decidim).to receive(:vapid_public_key).and_return("")
        end

        it "returns false" do
          expect(subject.meet_push_notifications_requirements?).to be false
        end
      end

      context "when the notifications requirements are not met" do
        before do
          allow(Decidim).to receive(:vapid_public_key).and_return(nil)
        end

        it "returns false" do
          expect(subject.meet_push_notifications_requirements?).to be false
        end
      end
    end
  end
end
