# frozen_string_literal: true

require "spec_helper"

describe Decidim::NotificationGeneratorJob do
  subject { described_class }

  describe "queue" do
    it "is queued to events" do
      expect(subject.queue_name).to eq "decidim_events"
    end
  end

  describe "perform" do
    let(:event) { double :event }
    let(:event_class) { Decidim::Events::BaseEvent }
    let(:event_class_name) { "Decidim::Events::BaseEvent" }
    let(:followable) { double :followable }
    let(:generator) { double :generator }

    it "delegates the work to the class" do
      expect(Decidim::NotificationGenerator)
        .to receive(:new)
        .with(event, event_class, followable)
        .and_return(generator)
      expect(generator)
        .to receive(:generate)

      subject.perform_now(event, event_class_name, followable)
    end
  end
end
