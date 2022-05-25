# frozen_string_literal: true

require "spec_helper"

describe Decidim::EventsManager do
  describe "#publish" do
    let(:event) { "my.event" }
    let(:event_class) { Decidim::Events::BaseEvent }
    let(:resource) { double }
    let(:extra) { double }
    let(:organization) { create :organization }
    let(:followers) { create_list :user, 3, organization: organization }
    let(:affected_users) { create_list :user, 3, organization: organization }
    let(:force_send) { true }

    it "delegates the params to ActiveSupport::Notifications" do
      expect(ActiveSupport::Notifications)
        .to receive(:publish)
        .with(
          event,
          event_class: "Decidim::Events::BaseEvent",
          resource: resource,
          followers: followers,
          affected_users: affected_users,
          force_send: force_send,
          extra: extra
        )

      described_class.publish(
        event: event,
        event_class: event_class,
        resource: resource,
        followers: followers,
        affected_users: affected_users,
        force_send: force_send,
        extra: extra
      )
    end

    context "when there are invalid values as affected_users" do
      let(:affected_users) { followers + followers + [nil] }

      it "sanitizes the recipients" do
        expect(ActiveSupport::Notifications)
          .to receive(:publish)
          .with(event, hash_including(affected_users: followers))

        described_class.publish(
          event: event,
          event_class: event_class,
          resource: resource,
          followers: followers,
          affected_users: affected_users,
          extra: extra
        )
      end
    end

    context "when there are invalid values as followers" do
      let(:followers) { affected_users + affected_users + [nil] }

      it "sanitizes the recipients" do
        expect(ActiveSupport::Notifications)
          .to receive(:publish)
          .with(event, hash_including(followers: affected_users))

        described_class.publish(
          event: event,
          event_class: event_class,
          resource: resource,
          followers: followers,
          affected_users: affected_users,
          extra: extra
        )
      end
    end
  end

  describe "#subscribe" do
    let(:event) { "my.event" }
    let(:block) { proc { "Hello world" } }

    it "delegates the params to ActiveSupport::Notifications" do
      allow(ActiveSupport::Notifications)
        .to receive(:subscribe)
        .with(event, &block)

      described_class.subscribe(event, &block)
    end
  end
end
