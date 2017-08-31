# frozen_string_literal: true

require "spec_helper"

describe Decidim::EventsManager do
  describe "#publish" do
    let(:event) { "my.event" }
    let(:event_class) { Decidim::Events::BaseEvent }
    let(:resource) { double }
    let(:user) { double }
    let(:recipient_ids) { [1, 2, 3] }

    it "delegates the params to ActiveSupport::Notifications" do
      expect(ActiveSupport::Notifications)
        .to receive(:publish)
        .with(event, event_class: "Decidim::Events::BaseEvent", resource: resource, user: user, recipient_ids: recipient_ids)

      described_class.publish(
        event: event,
        event_class: event_class,
        resource: resource,
        user: user,
        recipient_ids: recipient_ids
      )
    end
  end

  describe "#subscribe" do
    let(:event) { "my.event" }
    let(:block) { proc { "Hello world" } }

    it "delegates the params to ActiveSupport::Notifications" do
      expect(ActiveSupport::Notifications)
        .to receive(:subscribe)
        .with(event, &block)

      described_class.subscribe(event, &block)
    end
  end
end
