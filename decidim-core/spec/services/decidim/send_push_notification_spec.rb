# frozen_string_literal: true

require "spec_helper"

describe Decidim::SendPushNotification do
  subject { described_class.new }

  before do
    allow(Rails.application.secrets).to receive("vapid").and_return({ enabled: true, public_key: "public_key", private_key: "private_key" })
  end

  context "without vapid settings config" do
    before do
      allow(Rails.application.secrets).to receive("vapid").and_return({ enabled: false })
    end

    describe "#perform" do
      let(:user) { create(:user, allow_push_notifications: false) }
      let(:notification) { create :notification, user: user }

      it "returns false" do
        expect(subject.perform(notification)).to be_falsy
      end
    end
  end

  context "with a user that doesn't allow push notifications" do
    describe "#perform" do
      let(:user) { create(:user, allow_push_notifications: false) }
      let(:notification) { create :notification, user: user }

      it "returns false" do
        expect(subject.perform(notification)).to be_falsy
      end
    end
  end

  context "without subscription" do
    describe "#perform" do
      let(:user) { create(:user, allow_push_notifications: true) }
      let(:notification) { create :notification, user: user }

      it "returns false" do
        expect(subject.perform(notification)).to be_falsy
      end
    end
  end

  context "with subscription" do
    let(:user) { create(:user, allow_push_notifications: true) }
    let(:notification) { create :notification, user: user }
    let(:subscription) { build(:notifications_subscription) }

    before do
      user.notifications_subscriptions << subscription
    end

    describe "#perform" do
      it "returns 201 and created if the message is sent ok" do
        allow(Webpush).to receive(:payload_send).and_return(double("result", message: "Created", code: "201"))

        expect(subject.perform(notification).code).to eq("201")
        expect(subject.perform(notification).message).to eq("Created")
      end
    end

    describe "#notification_params" do
      let(:notification) { double("notification", title: "a_title", body: "a_body", icon: "an_icon", url: "a_url") }

      it "returns a hash with the notification fields" do
        result = subject.notification_params(notification)

        expect(result).to match(
          a_hash_including(
            title: "a_title",
            body: "a_body",
            icon: "an_icon",
            data: a_hash_including({ url: "a_url" })
          )
        )
      end
    end

    describe "#payload" do
      let(:message_params) { { title: "a_title", body: "a_body", icon: "an_icon", data: { url: "a_url" } } }
      let(:subscription) { build(:notifications_subscription) }

      it "returns true" do
        result = subject.payload(message_params, subscription)

        expect(result).to match(
          message: '{"title":"a_title","body":"a_body","icon":"an_icon","data":{"url":"a_url"}}',
          endpoint: subscription.endpoint,
          p256dh: subscription.p256dh,
          auth: subscription.auth,
          vapid: a_hash_including(
            public_key: "public_key",
            private_key: "private_key"
          )
        )
      end
    end
  end
end
