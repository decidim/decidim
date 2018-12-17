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
        newsletter_notifications_at: Time.current
      }
    end

    let(:form) do
      double(
        notification_types: "none",
        email_on_notification: data[:email_on_notification],
        newsletter_notifications_at: data[:newsletter_notifications_at],
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
      end
    end
  end
end
