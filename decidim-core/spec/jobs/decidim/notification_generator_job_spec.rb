# frozen_string_literal: true

require "spec_helper"

describe Decidim::NotificationGeneratorJob do
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
    let(:generator) { double :generator }
    let(:affected_user) { double :user, id: 1 }
    let(:affected_users) { [affected_user] }
    let(:follower) { double :user, id: 2 }
    let(:followers) { [follower] }
    let(:extra) { double }

    it "delegates the work to the class" do
      expect(Decidim::NotificationGenerator)
        .to receive(:new)
        .with(event, event_class, resource, match_array([1, 2]), extra)
        .and_return(generator)
      expect(generator)
        .to receive(:generate)

      subject.perform_now(event, event_class_name, resource, followers, affected_users, extra)
    end
  end
end
