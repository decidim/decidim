# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NotificationsSettingsForm do
    subject do
      described_class.new(
        email_on_notification: email_on_notification,
        newsletter_notifications: newsletter_notifications
      ).with_context(
        current_user: user
      )
    end

    let(:user) { create(:user) }

    let(:email_on_notification) { "1" }
    let(:newsletter_notifications) { "1" }

    context "with correct data" do
      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "with an empty email on notification" do
      let(:email_on_notification) { "" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end
    end

    context "with an empty newsletter notifications" do
      let(:newsletter_notifications) { "" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end
    end
  end
end
