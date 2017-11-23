# frozen_string_literal: true

require "spec_helper"

describe Decidim::NotificationGenerator do
  subject { described_class.new(event, event_class, resource, recipient_ids, extra) }

  let(:event) { "decidim.events.dummy.dummy_resource_updated" }
  let(:resource) { create(:dummy_resource) }
  let(:follow) { create(:follow, followable: resource, user: recipient) }
  let(:recipient) { resource.author }
  let(:event_class) { Decidim::Events::BaseEvent }
  let(:event_class_name) { "Decidim::Events::BaseEvent" }
  let(:recipient_ids) { [recipient.id] }
  let(:extra) { double }

  describe "generate" do
    context "when the event_class supports notifications" do
      before do
        allow(event_class).to receive(:types).and_return([:notification])
      end

      it "schedules a job for each recipient" do
        expect(Decidim::NotificationGeneratorForRecipientJob)
          .to receive(:perform_later)
          .with(event, event_class_name, resource, recipient.id, extra)

        subject.generate
      end
    end

    context "when the event_class supports notifications" do
      before do
        allow(event_class).to receive(:types).and_return([])
      end

      it "schedules a job for each recipient" do
        expect(Decidim::NotificationGeneratorForRecipientJob)
          .not_to receive(:perform_later)

        subject.generate
      end
    end
  end
end
