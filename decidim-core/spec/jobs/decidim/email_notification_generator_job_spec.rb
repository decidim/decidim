# frozen_string_literal: true

require "spec_helper"

describe Decidim::EmailNotificationGeneratorJob do
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
    let(:recipient_ids) { [1, 2, 3] }
    let(:extra) { double }

    it "delegates the work to the class" do
      expect(Decidim::EmailNotificationGenerator)
        .to receive(:new)
        .with(event, event_class, resource, recipient_ids, extra)
        .and_return(generator)
      expect(generator)
        .to receive(:generate)

      subject.perform_now(event, event_class_name, resource, recipient_ids, extra)
    end
  end
end
