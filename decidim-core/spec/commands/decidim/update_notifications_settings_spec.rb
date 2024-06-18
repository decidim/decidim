# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UpdateNotificationsSettings do
    let(:command) { described_class.new(form) }
    let(:user) { create(:user) }
    let(:valid) { true }
    let(:data) do
      {
        email_on_moderations: false,
        email_on_assigned_proposals: false,
        newsletter_notifications_at: Time.current,
        direct_message_types: "followed-only",
        notification_settings: { close_meeting_reminder: "0" },
        notifications_sending_frequency: "weekly"
      }
    end

    let(:form) do
      double(
        notification_types: "none",
        email_on_moderations: data[:email_on_moderations],
        email_on_assigned_proposals: data[:email_on_assigned_proposals],
        newsletter_notifications_at: data[:newsletter_notifications_at],
        direct_message_types: data[:direct_message_types],
        notification_settings: data[:notification_settings],
        notifications_sending_frequency: data[:notifications_sending_frequency],
        valid?: valid,
        current_user: user
      )
    end

    context "when invalid" do
      let(:valid) { false }

      it "Does not update anything" do
        expect { command.call }.to broadcast(:invalid)
      end
    end

    context "when valid" do
      let(:valid) { true }

      it "updates the users's notifications settings" do
        expect { command.call }.to broadcast(:ok)
        user.reload
        expect(user.newsletter_notifications_at).not_to be_nil
        expect(user.notification_types).to eq "none"
        expect(user.direct_message_types).to eq "followed-only"
        expect(user.notification_settings["close_meeting_reminder"]).to eq "0"
        expect(user.notifications_sending_frequency).to eq "weekly"
        expect(user.email_on_moderations).to be_false
        expect(user.email_on_assigned_proposals).to be_false
      end
    end
  end
end
