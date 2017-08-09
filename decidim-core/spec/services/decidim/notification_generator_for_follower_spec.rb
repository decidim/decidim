# frozen_string_literal: true

require "spec_helper"

describe Decidim::NotificationGeneratorForFollower do
  let(:event) { "decidim.events.dummy.dummy_resource_updated" }
  let(:followable) { create(:dummy_resource) }
  let(:follow) { create(:follow, followable: followable, user: follower) }
  let(:follower) { followable.author }
  let(:event_class) { Decidim::Events::BaseEvent }
  subject { described_class.new(event, event_class, followable, follower) }

  describe "generate" do
    it "creates a notification for the follower" do
      expect do
        subject.generate
      end.to change(Decidim::Notification, :count).by(1)
      notification = Decidim::Notification.last

      expect(notification.user).to eq follower
      expect(notification.notification_type).to eq event
      expect(notification.followable).to eq followable
    end

    context "when it is not notifiable for the given user" do
      it "returns nil" do
        allow(followable).to receive(:notifiable?).and_return(false)
        expect(subject.generate).to be_nil
      end
    end
  end
end
