# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NotificationsSubscriptionsPersistor, type: :service do
    subject { described_class.new(user) }

    let(:organization) { create(:organization, colors: { "theme" => "#f0f0f0" }) }
    let(:params) { { endpoint: "https://example.es", keys: { auth: "auth_code_121", p256dh: "a_p256dh" } } }
    let(:user) { create(:user, organization: organization) }

    describe "#add_subscription" do
      it "returns the result of the subscription persistance" do
        expect(subject.add_subscription(params)).to be_truthy
        expect(user.notifications_subscriptions).not_to be_empty
      end
    end

    describe "#delete_subscription" do
      let(:user) { create(:user, organization: organization, "notification_settings" => { "subscriptions" => { "auth_code_121" => { p256dh: "value", endpoint: "value" } } }) }

      it "returns the result of the subscription deletion" do
        expect(subject.delete_subscription("auth_code_121")).to be_truthy
        expect(user.notifications_subscriptions).to be_empty
      end
    end
  end
end
