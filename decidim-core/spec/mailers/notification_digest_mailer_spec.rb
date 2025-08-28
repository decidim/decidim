# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NotificationsDigestMailer do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, name: "Sarah Connor", organization:) }
    let(:notification_ids) { [notification.id] }
    let(:notification) { create(:notification, user:, resource:) }
    let(:component) { create(:component, manifest_name: "dummy", organization:) }
    let(:resource) { create(:dummy_resource, title: { en: %(Testing <a href="/resource">resource</a>) }, component:) }

    describe "digest_mail" do
      subject { described_class.digest_mail(user, notification_ids) }

      it "includes the link to the resource" do
        expect(subject.body).to include(
          %(<a href="#{::Decidim::ResourceLocatorPresenter.new(resource).url}">Testing resource</a>)
        )
      end

      context "when the notification is a comment" do
        let(:comment) { create(:comment, body: "This is a comment") }
        let(:event_name) { "decidim.events.comments.comment_created" }
        let(:event_class) { "Decidim::Comments::CommentCreatedEvent" }
        let(:extra) { { "comment_id" => comment.id, "received_as" => "follower" } }
        let(:notification) { create(:notification, user:, resource:, event_name:, event_class:, extra:) }

        it "includes the comment body" do
          expect(subject.body).to include("This is a comment")
        end
      end

      context "when the notification does not send emails" do
        let(:notification) { create(:notification, user:, resource:, event_class: "Decidim::Dev::DummyNotificationOnlyResourceEvent") }

        it "does not include the notification" do
          expect(subject.body).not_to include("Testing resource")
        end
      end
    end
  end
end
