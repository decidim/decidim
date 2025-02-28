# frozen_string_literal: true

require "spec_helper"

describe Decidim::PushNotificationMessageSender do
  let(:organization) { build(:organization) }
  let(:conversation) { create(:conversation) }
  let(:third_party) { build(:user, organization:) }
  let(:message) { build(:message) }
  let(:originator) { build(:user, organization:) }
  let(:sender) { build(:user, organization:) }
  let(:user) { build(:user, organization:) }
  let(:notification) { build(:push_notification_message) }
  let(:notification_sender) { double :notification_sender }
  let(:title) { nil }
  let(:push_notification_message) { build(:push_notification_message, sender:, third_party:, conversation:, action:) }

  shared_examples "a push notification" do
    it "gets the correct title" do
      expect(subject.send(:title)).to eq(push_notification_title)
    end

    it "calls push notification" do
      send_push_notification_double = instance_double(Decidim::SendPushNotification)
      allow(Decidim::SendPushNotification).to receive(:new).and_return(send_push_notification_double)
      expect(send_push_notification_double).to receive(:perform)
      subject.deliver
    end
  end

  describe ".new_conversation" do
    subject { described_class.new.new_conversation(originator, user, conversation) }

    let(:action) { "new_conversation" }
    let(:push_notification_title) { "#{user.name} has started a conversation with you" }

    it_behaves_like "a push notification"
  end

  describe ".new_message" do
    subject { described_class.new.new_message(sender, user, conversation, message) }

    let(:push_notification_title) { "You have new messages from #{user.name}" }
    let(:action) { "new_message" }

    it_behaves_like "a push notification"
  end
end
