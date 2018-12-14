# frozen_string_literal: true

require "spec_helper"

describe Decidim::EmailNotificationGenerator do
  subject { described_class.new(event, event_class, resource, followers, affected_users, extra) }

  let(:event) { "decidim.events.dummy.dummy_resource_updated" }
  let(:resource) { create(:dummy_resource) }
  let(:follow) { create(:follow, followable: resource, user: recipient) }
  let(:recipient) { resource.author }
  let(:event_class) { Decidim::Events::BaseEvent }
  let(:event_class_name) { "Decidim::Events::BaseEvent" }
  let(:affected_users) { [recipient] }
  let(:follower) { create :user }
  let(:followers) { [follower] }
  let(:extra) { double }

  describe "generate" do
    context "when the event_class supports emails" do
      let(:mailer) { double(deliver_later: true) }

      before do
        allow(event_class).to receive(:types).and_return([:email])
      end

      context "when the user does not want emails for notifications" do
        before do
          recipient.update(email_on_notification: false)
          follower.update(email_on_notification: false)
        end

        it "does not schedule a job for that recipient" do
          expect(Decidim::NotificationMailer)
            .not_to receive(:event_received)

          subject.generate
        end
      end

      context "when the user wants emails for notifications" do
        before do
          recipient.update!(email_on_notification: true)
          follower.update!(email_on_notification: true)
        end

        it "schedules a job for each recipient" do
          expect(Decidim::NotificationMailer)
            .to receive(:event_received)
            .with(event, event_class_name, resource, recipient, extra)
            .and_return(mailer)
          expect(Decidim::NotificationMailer)
            .to receive(:event_received)
            .with(event, event_class_name, resource, follower, extra)
            .and_return(mailer)
          expect(mailer).to receive(:deliver_later)

          subject.generate
        end
      end
    end

    context "when the event_class does not support emails" do
      before do
        allow(event_class).to receive(:types).and_return([])
      end

      it "schedules a job for each recipient" do
        expect(Decidim::NotificationMailer)
          .not_to receive(:event_received)

        subject.generate
      end
    end
  end
end
