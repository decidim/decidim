# frozen_string_literal: true

require "spec_helper"

describe Decidim::NotificationGeneratorForRecipient do
  subject { described_class.new(event, event_class, resource, recipient, :affected_user, extra) }

  let(:event) { "decidim.events.dummy.dummy_resource_updated" }
  let(:resource) { create(:dummy_resource, published_at: Time.current) }
  let(:follow) { create(:follow, followable: resource, user: recipient) }
  let(:recipient) { resource.author }
  let(:extra) { {} }
  let(:event_class) { Decidim::Events::BaseEvent }

  describe "generate" do
    it "creates a notification for the recipient" do
      expect do
        subject.generate
      end.to change(Decidim::Notification, :count).by(1)
      notification = Decidim::Notification.last

      expect(notification.user).to eq recipient
      expect(notification.event_name).to eq event
      expect(notification.resource).to eq resource
      expect(notification.extra["received_as"]).to eq "affected_user"
    end

    context "when the event is not notifiable" do
      class NonNotifiableEvent < Decidim::Events::BaseEvent
        def notifiable?
          false
        end
      end
      let(:event_class) { NonNotifiableEvent }

      it "does not create the notification" do
        expect do
          subject.generate
        end.not_to change(Decidim::Notification, :count)
      end
    end
  end
end
