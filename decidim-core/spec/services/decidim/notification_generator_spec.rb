# frozen_string_literal: true

require "spec_helper"

describe Decidim::NotificationGenerator do
  subject { described_class.new(event, event_class, resource, followers, affected_users, extra) }

  let(:event) { "decidim.events.dummy.dummy_resource_updated" }
  let(:resource) { create(:dummy_resource) }
  let(:follow) { create(:follow, followable: resource, user: affected_user) }
  let(:affected_user) { resource.author }
  let(:event_class) { Decidim::Events::BaseEvent }
  let(:event_class_name) { "Decidim::Events::BaseEvent" }
  let(:affected_users) { [affected_user] }
  let(:follower) { create :user }
  let(:followers) { [follower] }
  let(:extra) { double }

  describe "generate" do
    context "when the event_class supports notifications" do
      before do
        allow(event_class).to receive(:types).and_return([:notification])
      end

      describe "followers" do
        let(:affected_users) { [] }

        context "when the follower asks for notifications on all" do
          let(:follower) { create :user, notification_types: "all" }

          it "sends the notification" do
            expect(Decidim::NotificationGeneratorForRecipientJob)
              .to receive(:perform_later)
              .with(event, event_class_name, resource, follower, :follower.to_s, extra)
            subject.generate
          end
        end

        context "when the follower asks for notifications on followed" do
          let(:follower) { create :user, notification_types: "followed-only" }

          it "sends the notification" do
            expect(Decidim::NotificationGeneratorForRecipientJob)
              .to receive(:perform_later)
              .with(event, event_class_name, resource, follower, :follower.to_s, extra)
            subject.generate
          end
        end

        context "when the follower asks for notifications on none" do
          let(:follower) { create :user, notification_types: "none" }

          it "sends the notification" do
            expect(Decidim::NotificationGeneratorForRecipientJob)
              .not_to receive(:perform_later)
              .with(event, event_class_name, resource, follower, :follower.to_s, extra)
            subject.generate
          end
        end

        context "when the follower asks for notifications on own-only" do
          let(:follower) { create :user, notification_types: "own-only" }

          it "sends the notification" do
            expect(Decidim::NotificationGeneratorForRecipientJob)
              .not_to receive(:perform_later)
              .with(event, event_class_name, resource, follower, :follower.to_s, extra)
            subject.generate
          end
        end
      end

      describe "affected_users" do
        let(:followers) { [] }

        context "when the affected_user asks for notifications on all" do
          let(:affected_user) { create :user, notification_types: "all" }

          it "sends the notification" do
            expect(Decidim::NotificationGeneratorForRecipientJob)
              .to receive(:perform_later)
              .with(event, event_class_name, resource, affected_user, :affected_user.to_s, extra)
            subject.generate
          end
        end

        context "when the affected_user asks for notifications on followed" do
          let(:affected_user) { create :user, notification_types: "followed-only" }

          it "sends the notification" do
            expect(Decidim::NotificationGeneratorForRecipientJob)
              .not_to receive(:perform_later)
              .with(event, event_class_name, resource, affected_user, :affected_user.to_s, extra)
            subject.generate
          end
        end

        context "when the affected_user asks for notifications on none" do
          let(:affected_user) { create :user, notification_types: "none" }

          it "sends the notification" do
            expect(Decidim::NotificationGeneratorForRecipientJob)
              .not_to receive(:perform_later)
              .with(event, event_class_name, resource, affected_user, :affected_user.to_s, extra)
            subject.generate
          end
        end

        context "when the affected_user asks for notifications on own-only" do
          let(:affected_user) { create :user, notification_types: "own-only" }

          it "sends the notification" do
            expect(Decidim::NotificationGeneratorForRecipientJob)
              .to receive(:perform_later)
              .with(event, event_class_name, resource, affected_user, :affected_user.to_s, extra)
            subject.generate
          end
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
            expect(Decidim::NotificationGeneratorForRecipientJob)
              .to receive(:perform_later).twice

            subject.generate
          end
        end

        context "and the user can't participate" do
          before do
            allow(resource).to receive(:can_participate?).with(kind_of(Decidim::User)).and_return(false)
          end

          it "doesn't schedule a job" do
            expect(Decidim::NotificationGeneratorForRecipientJob)
              .not_to receive(:perform_later)

            subject.generate
          end
        end
      end
    end

    context "when the event_class does not support notifications" do
      before do
        allow(event_class).to receive(:types).and_return([])
      end

      it "doesn't schedule a job for each recipient" do
        expect(Decidim::NotificationGeneratorForRecipientJob)
          .not_to receive(:perform_later)

        subject.generate
      end
    end
  end
end
