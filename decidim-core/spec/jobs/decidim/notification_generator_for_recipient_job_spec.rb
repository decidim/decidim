# frozen_string_literal: true

require "spec_helper"

describe Decidim::NotificationGeneratorForRecipientJob do
  subject { described_class }

  describe "queue" do
    it "is queued to events" do
      expect(subject.queue_name).to eq "events"
    end
  end

  describe "perform" do
    let(:event) { double :event }
    let(:event_class) { Decidim::Events::BaseEvent }
    let(:event_class_name) { "Decidim::Events::BaseEvent" }
    let(:resource) { double :resource }
    let(:recipient) { double :recipient }
    let(:extra) { double }
    let(:generator) { double :generator }
    let(:notification) { double :notification }
    let(:notification_sender) { double :notification_sender }

    it "delegates the work to the class" do
      allow(Decidim::NotificationGeneratorForRecipient)
        .to receive(:new)
        .with(event, event_class, resource, recipient, :follower, extra)
        .and_return(generator)
      allow(generator)
        .to receive(:generate)
        .and_return(notification)

      allow(Decidim::SendPushNotification)
        .to receive(:new)
        .and_return(notification_sender)
      expect(notification_sender)
        .to receive(:perform)
        .with(notification)

      subject.perform_now(event, event_class_name, resource, recipient, :follower, extra)
    end
  end
end
