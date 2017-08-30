# frozen_string_literal: true

require "spec_helper"

describe Decidim::EventsManager do
  describe "#publish" do
    let(:event) { "my.event" }
    let(:event_class) { Decidim::Events::BaseEvent }
    let(:resource) { double }
    let(:user) { double }

    it "delegates the params to ActiveSupport::Notifications" do
      expect(ActiveSupport::Notifications)
        .to receive(:publish)
        .with(event, event_class: "Decidim::Events::BaseEvent", resource: resource, user: user)

      described_class.publish(event: event, event_class: event_class, resource: resource, user: user)
    end
  end
end
