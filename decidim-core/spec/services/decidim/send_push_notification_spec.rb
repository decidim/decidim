# frozen_string_literal: true

require "spec_helper"

describe Decidim::SendPushNotification do
  subject { described_class.new }

  let(:subscription) { { "auth_key_1" => { "auth" => "auth_key_1", "p256dh" => "p256dh_1", "endpoint" => "endpoint_1" } } }
  let(:subscriptions) do
    {
      "auth_key_1" => { "auth" => "auth_key_1", "p256dh" => "p256dh_1", "endpoint" => "endpoint_1" },
      "auth_key_2" => { "auth" => "auth_key_2", "p256dh" => "p256dh_2", "endpoint" => "endpoint_2" },
      "auth_key_3" => { "auth" => "auth_key_3", "p256dh" => "p256dh_3", "endpoint" => "endpoint_3" }
    }
  end

  before do
    allow(Rails.application.secrets).to receive("vapid").and_return({ enabled: true, public_key: "public_key", private_key: "private_key" })
  end

  context "without vapid settings config" do
    before do
      allow(Rails.application.secrets).to receive("vapid").and_return({ enabled: false })
    end

    describe "#perform" do
      let(:user) { create(:user) }
      let(:notification) { create :notification, user: }

      it "returns false" do
        expect(subject.perform(notification)).to be_falsy
      end
    end
  end

  context "without any subscription" do
    describe "#perform" do
      let(:user) { create(:user, notification_settings: { subscriptions: {} }) }
      let(:notification) { create :notification, user: }

      it "returns empty array" do
        expect(subject.perform(notification)).to be_empty
      end
    end
  end

  context "with subscriptions" do
    let(:user) { create(:user, notification_settings: { subscriptions: }) }
    let(:notification) { create :notification, user: }

    describe "#perform" do
      it "returns 201 and created if the message is sent ok" do
        presented_notification = Decidim::PushNotificationPresenter.new(notification)
        message = JSON.generate({
                                  title: presented_notification.title,
                                  body: presented_notification.body,
                                  icon: presented_notification.icon,
                                  data: { url: presented_notification.url }
                                })

        first_notification_payload = {
          message:,
          endpoint: subscriptions["auth_key_1"]["endpoint"],
          p256dh: subscriptions["auth_key_1"]["p256dh"],
          auth: subscriptions["auth_key_1"]["auth"],
          vapid: a_hash_including(
            public_key: "public_key",
            private_key: "private_key"
          )
        }
        second_notification_payload = {
          message:,
          endpoint: subscriptions["auth_key_2"]["endpoint"],
          p256dh: subscriptions["auth_key_2"]["p256dh"],
          auth: subscriptions["auth_key_2"]["auth"],
          vapid: a_hash_including(
            public_key: "public_key",
            private_key: "private_key"
          )
        }
        third_notification_payload = {
          message:,
          endpoint: subscriptions["auth_key_3"]["endpoint"],
          p256dh: subscriptions["auth_key_3"]["p256dh"],
          auth: subscriptions["auth_key_3"]["auth"],
          vapid: a_hash_including(
            public_key: "public_key",
            private_key: "private_key"
          )
        }
        expect(Webpush).to receive(:payload_send).with(first_notification_payload).ordered.and_return(double("result", message: "Created", code: "201"))
        expect(Webpush).to receive(:payload_send).with(second_notification_payload).ordered.and_return(double("result", message: "Created", code: "201"))
        expect(Webpush).to receive(:payload_send).with(third_notification_payload).ordered.and_raise(Webpush::Error)

        responses = subject.perform(notification)
        expect(responses.size).to eq(2)
        expect(responses.all? { |response| response.code == "201" }).to be(true)
        expect(responses.all? { |response| response.message == "Created" }).to be(true)
      end
    end
  end

  context "with subscription" do
    let(:user) { create(:user, notification_settings: { subscriptions: subscription }) }
    let(:notification) { create :notification, user: }

    describe "#perform" do
      it "returns 201 and created if the message is sent ok" do
        presented_notification = Decidim::PushNotificationPresenter.new(notification)
        notification_payload = {
          message: JSON.generate({
                                   title: presented_notification.title,
                                   body: presented_notification.body,
                                   icon: presented_notification.icon,
                                   data: { url: presented_notification.url }
                                 }),
          endpoint: subscriptions["auth_key_1"]["endpoint"],
          p256dh: subscriptions["auth_key_1"]["p256dh"],
          auth: subscriptions["auth_key_1"]["auth"],
          vapid: a_hash_including(
            public_key: "public_key",
            private_key: "private_key"
          )
        }

        allow(Webpush).to receive(:payload_send).with(notification_payload).and_return(double("result", message: "Created", code: "201"))

        responses = subject.perform(notification)
        expect(responses.all? { |response| response.code == "201" }).to be(true)
        expect(responses.all? { |response| response.message == "Created" }).to be(true)
      end

      it "builds notification in user locale" do
        # Pick other locale from organization
        alternative_locale = (user.organization.available_locales - [user.locale]).sample
        user.update(locale: alternative_locale)

        I18n.with_locale(user.locale) do
          presented_notification = Decidim::PushNotificationPresenter.new(notification)
          message = JSON.generate({
                                    title: presented_notification.title,
                                    body: presented_notification.body,
                                    icon: presented_notification.icon,
                                    data: { url: presented_notification.url }
                                  })

          notification_payload = a_hash_including(message:)
          expect(Webpush).to receive(:payload_send).with(notification_payload).ordered.and_return(double("result", message: "Created", code: "201"))
        end

        responses = subject.perform(notification)
        expect(responses.all? { |response| response.code == "201" }).to be(true)
        expect(responses.all? { |response| response.message == "Created" }).to be(true)
      end
    end
  end
end
