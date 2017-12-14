# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UnsubscribeNotificationsSettings do
    let(:command) { described_class.new(user) }
    let(:user) { create(:user, newsletter_notifications: true) }
    let(:newsletter_notifications) { true }

    context "when newsletter notifications are true" do
      let(:newsletter_notifications) { true }

      it "Unsubscribe user" do
        expect { command.call }.to broadcast(:ok, user)
      end
    end

    context "when newsletter notifications are false" do
      let(:user) { create(:user, newsletter_notifications: false) }
      let(:newsletter_notifications) { false }

      it "return to user notifications url" do
        expect { command.call }.to broadcast(:invalid)
      end
    end
  end
end
