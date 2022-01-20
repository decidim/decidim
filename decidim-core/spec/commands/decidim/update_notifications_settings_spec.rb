# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UpdateNotificationsSettings do
    let(:command) { described_class.new(user, form) }
    let(:user) { create(:user) }
    let(:valid) { true }
    let(:data) do
      {
        email_on_notification: true,
        email_on_moderations: true,
        allow_push_notifications: true,
        newsletter_notifications_at: Time.current,
        direct_message_types: "followed-only",
        notification_settings: { "close_meeting_reminder": "0" }
      }
    end

    let(:form) do
      double(
        notification_types: "none",
        email_on_notification: data[:email_on_notification],
        email_on_moderations: data[:email_on_moderations],
        newsletter_notifications_at: data[:newsletter_notifications_at],
        direct_message_types: data[:direct_message_types],
        notification_settings: data[:notification_settings],
        allow_push_notifications: data[:allow_push_notifications],
        valid?: valid
      )
    end

    context "when invalid" do
      let(:valid) { false }

      it "Doesn't update anything" do
        expect { command.call }.to broadcast(:invalid)
      end
    end

    context "when valid" do
      let(:valid) { true }

      it "updates the users's notifications settings" do
        expect { command.call }.to broadcast(:ok)
        user.reload
        expect(user.email_on_notification).to be_truthy
        expect(user.newsletter_notifications_at).not_to be_nil
        expect(user.notification_types).to eq "none"
        expect(user.direct_message_types).to eq "followed-only"
        expect(user.notification_settings["close_meeting_reminder"]).to eq "0"
        expect(user.allow_push_notifications).to be_truthy
      end
    end
  end
end
