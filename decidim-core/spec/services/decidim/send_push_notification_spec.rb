# frozen_string_literal: true

require "spec_helper"

describe Decidim::SendPushNotification do
  subject { described_class.new }

  let(:subscriptions) { {} }
  let(:user) { create(:user, notification_settings: { subscriptions: }) }

  before do
    allow(Decidim).to receive(:vapid_public_key).and_return("public_key")
    allow(Decidim).to receive(:vapid_private_key).and_return("private_key")
  end

  shared_examples "send a push notification" do
    context "without vapid settings config" do
      before do
        allow(Decidim).to receive(:vapid_public_key).and_return("")
        allow(Decidim).to receive(:vapid_private_key).and_return("")
      end

      describe "#perform" do
        it "returns false" do
          expect(subject.perform(notification, title)).to be_falsy
        end
      end
    end

    context "without vapid enabled" do
      before do
        allow(Decidim).to receive(:vapid_public_key).and_return("")
      end

      describe "#perform" do
        it "returns false" do
          expect(subject.perform(notification, title)).to be_falsy
        end
      end
    end

    context "without any subscription" do
      let(:subscriptions) { {} }

      describe "#perform" do
        it "returns empty array" do
          expect(subject.perform(notification, title)).to be_empty
        end
      end
    end

    context "with subscriptions" do
      let(:subscriptions) do
        {
          "auth_key_1" => { "auth" => "auth_key_1", "p256dh" => "p256dh_1", "endpoint" => "endpoint_1" },
          "auth_key_2" => { "auth" => "auth_key_2", "p256dh" => "p256dh_2", "endpoint" => "endpoint_2" },
          "auth_key_3" => { "auth" => "auth_key_3", "p256dh" => "p256dh_3", "endpoint" => "endpoint_3" }
        }
      end

      describe "#perform" do
        it "returns 201 and created if the message is sent ok" do
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
          expect(WebPush).to receive(:payload_send).with(first_notification_payload).ordered.and_return(double("result", message: "Created", code: "201"))
          expect(WebPush).to receive(:payload_send).with(second_notification_payload).ordered.and_return(double("result", message: "Created", code: "201"))
          expect(WebPush).to receive(:payload_send).with(third_notification_payload).ordered.and_raise(WebPush::Error)

          responses = subject.perform(notification, title)
          expect(responses.size).to eq(2)
          expect(responses.all? { |response| response.code == "201" }).to be(true)
          expect(responses.all? { |response| response.message == "Created" }).to be(true)
        end
      end
    end

    context "with subscription" do
      let(:subscriptions) { { "auth_key_1" => { "auth" => "auth_key_1", "p256dh" => "p256dh_1", "endpoint" => "endpoint_1" } } }

      describe "#perform" do
        it "returns 201 and created if the message is sent ok" do
          notification_payload = {
            message:,
            endpoint: subscriptions["auth_key_1"]["endpoint"],
            p256dh: subscriptions["auth_key_1"]["p256dh"],
            auth: subscriptions["auth_key_1"]["auth"],
            vapid: a_hash_including(
              public_key: "public_key",
              private_key: "private_key"
            )
          }

          allow(WebPush).to receive(:payload_send).with(notification_payload).and_return(double("result", message: "Created", code: "201"))

          responses = subject.perform(notification, title)
          expect(responses.all? { |response| response.code == "201" }).to be(true)
          expect(responses.all? { |response| response.message == "Created" }).to be(true)
        end

        it "builds notification in user locale" do
          # Pick other locale from organization
          alternative_locale = (user.organization.available_locales - [user.locale]).sample
          user.update(locale: alternative_locale)

          I18n.with_locale(user.locale) do
            notification_payload = a_hash_including(message:)
            expect(WebPush).to receive(:payload_send).with(notification_payload).ordered.and_return(double("result", message: "Created", code: "201"))
          end

          responses = subject.perform(notification, title)
          expect(responses.all? { |response| response.code == "201" }).to be(true)
          expect(responses.all? { |response| response.message == "Created" }).to be(true)
        end
      end
    end
  end

  context "with a Decidim::Notification" do
    let(:notification) { create(:notification, user:) }
    let(:presented_notification) { Decidim::PushNotificationPresenter.new(notification) }
    let(:message) do
      JSON.generate({
                      title: presented_notification.title,
                      body: presented_notification.body,
                      icon: presented_notification.icon,
                      data: { url: presented_notification.url }
                    })
    end
    let(:title) { nil }

    it_behaves_like "send a push notification"
  end

  context "with a Decidim::PushNotificationMessage" do
    let(:notification) { build(:push_notification_message, recipient: user) }
    let(:message) do
      JSON.generate({
                      title:,
                      body: notification.body,
                      icon: notification.icon,
                      data: { url: notification.url }
                    })
    end
    let(:title) { "A new message from #{user.name}" }

    it_behaves_like "send a push notification"

    context "without title" do
      let(:title) { nil }

      it "raises an ArgumentError" do
        expect { subject.perform(notification) }.to raise_error(ArgumentError, "Need to provide a title if the notification is a PushNotificationMessage")
      end
    end
  end
end
