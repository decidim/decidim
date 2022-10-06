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
          recipient.update(notifications_sending_frequency: "none")
          follower.update(notifications_sending_frequency: "none")
        end

        it "does not schedule a job for that recipient" do
          expect(Decidim::NotificationMailer)
            .not_to receive(:event_received)

          subject.generate
        end
      end

      context "when the user wants emails for notifications" do
        before do
          recipient.update!(notifications_sending_frequency: "real_time")
          follower.update!(notifications_sending_frequency: "real_time")
        end

        it "schedules a job for each recipient" do
          allow(Decidim::NotificationMailer)
            .to receive(:event_received)
            .with(event, event_class_name, resource, recipient, :affected_user.to_s, extra)
            .and_return(mailer)

          allow(Decidim::NotificationMailer)
            .to receive(:event_received)
            .with(event, event_class_name, resource, follower, :follower.to_s, extra)
            .and_return(mailer)

          expect(mailer).to receive(:deliver_later)

          subject.generate
        end
      end

      context "when participatory space is participable" do
        before do
          resource.published_at = Time.current
          resource.component.published_at = Time.current
          resource.component.participatory_space.published_at = Time.current
          resource.save!
        end

        context "and the user can participate" do
          it "enqueues the job" do
            allow(Decidim::NotificationMailer)
              .to receive(:event_received)
              .with(event, event_class_name, resource, recipient, :affected_user.to_s, extra)
              .and_return(mailer)

            allow(Decidim::NotificationMailer)
              .to receive(:event_received)
              .with(event, event_class_name, resource, follower, :follower.to_s, extra)
              .and_return(mailer)

            expect(mailer).to receive(:deliver_later)

            subject.generate
          end
        end

        context "and the user can't participate" do
          before do
            allow(resource).to receive(:can_participate?).with(kind_of(Decidim::User)).and_return(false)
          end

          it "doesn't schedule a job" do
            expect(Decidim::NotificationMailer)
              .not_to receive(:event_received)

            subject.generate
          end
        end
      end
    end

    context "when the event_class does not support emails" do
      before do
        allow(event_class).to receive(:types).and_return([])
      end

      it "doesn't schedule a job for each recipient" do
        expect(Decidim::NotificationMailer)
          .not_to receive(:event_received)

        subject.generate
      end
    end
  end
end
