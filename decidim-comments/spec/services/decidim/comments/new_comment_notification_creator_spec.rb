# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::NewCommentNotificationCreator do
  subject { described_class.new(comment, mentioned_users) }

  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:component) { create(:component, participatory_space: participatory_process) }
  let(:dummy_resource) { create(:dummy_resource, component:, author: commentable_author) }
  let(:commentable) { dummy_resource }
  let(:mentioned_user) { create(:user, organization:) }
  let(:another_mentioned_user) { create(:user, organization:) }
  let(:user_following_comment_author) { create(:user, organization:) }
  let(:commentable_author) { create(:user, organization:) }
  let(:commentable_recipient) { create(:user, organization:) }

  let(:mentioned_users) do
    Decidim::User.where(
      id: [
        mentioned_user.id,
        another_mentioned_user.id
      ]
    )
  end
  let(:commentable_recipients) do
    Decidim::User.where(
      id: [
        commentable_recipient.id,
        commentable_author.id
      ]
    )
  end

  before do
    allow(commentable)
      .to receive(:users_to_notify_on_comment_created)
      .and_return(commentable_recipients)
  end

  describe "when the author is a user" do
    let(:comment_author) { create(:user, organization:) }
    let(:comment) { create(:comment, author: comment_author, commentable:, root_commentable: dummy_resource) }

    before do
      create(:follow, user: user_following_comment_author, followable: comment_author)
    end

    it "notifies the mentioned users" do
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .once
        .ordered
        .with(
          event: "decidim.events.comments.user_mentioned",
          event_class: Decidim::Comments::UserMentionedEvent,
          resource: dummy_resource,
          affected_users: a_collection_containing_exactly(*mentioned_users),
          extra: {
            comment_id: comment.id
          }
        )
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .twice
        .ordered

      subject.create
    end

    context "when the author mentions herself" do
      let(:mentioned_users_to_notify) do
        Decidim::User.where(
          id: [
            mentioned_user.id,
            another_mentioned_user.id
          ]
        )
      end
      let(:mentioned_users) do
        Decidim::User.where(
          id: [
            comment_author.id,
            mentioned_user.id,
            another_mentioned_user.id
          ]
        )
      end

      it "does not notify herself" do
        expect(Decidim::EventsManager)
          .to receive(:publish)
          .once
          .ordered
          .with(
            event: "decidim.events.comments.user_mentioned",
            event_class: Decidim::Comments::UserMentionedEvent,
            resource: dummy_resource,
            affected_users: a_collection_containing_exactly(*mentioned_users_to_notify),
            extra: {
              comment_id: comment.id
            }
          )
        expect(Decidim::EventsManager)
          .to receive(:publish)
          .twice
          .ordered

        subject.create
      end
    end

    it "notifies the followers of the author" do
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .once
        .ordered

      expect(Decidim::EventsManager)
        .to receive(:publish)
        .once
        .ordered
        .with(
          event: "decidim.events.comments.comment_by_followed_user",
          event_class: Decidim::Comments::CommentByFollowedUserEvent,
          resource: dummy_resource,
          followers: a_collection_containing_exactly(user_following_comment_author),
          extra: {
            comment_id: comment.id
          }
        )
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .once
        .ordered

      subject.create
    end

    it "notifies the commentable recipients" do
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .twice
        .ordered

      expect(Decidim::EventsManager)
        .to receive(:publish)
        .once
        .ordered
        .with(
          event: "decidim.events.comments.comment_created",
          event_class: Decidim::Comments::CommentCreatedEvent,
          resource: dummy_resource,
          followers: a_collection_containing_exactly(*commentable_recipients),
          extra: {
            comment_id: comment.id
          }
        )

      subject.create
    end

    context "when comment author is a commentable recipient" do
      let(:commentable_recipients) do
        Decidim::User.where(
          id: [
            comment_author.id,
            commentable_recipient.id,
            commentable_author.id
          ]
        )
      end

      it "does not notify comment author even if it is following the commentable" do
        expect(Decidim::EventsManager)
          .to receive(:publish)
          .twice
          .ordered

        expect(Decidim::EventsManager)
          .to receive(:publish)
          .once
          .ordered
          .with(
            event: "decidim.events.comments.comment_created",
            event_class: Decidim::Comments::CommentCreatedEvent,
            resource: dummy_resource,
            followers: a_collection_containing_exactly(commentable_recipient, commentable_author),
            extra: {
              comment_id: comment.id
            }
          )

        subject.create
      end
    end

    context "when replying another comment" do
      let(:commentable) { top_level_comment }

      context "when comment author is replying to herself" do
        let(:top_level_comment) { create(:comment, commentable: dummy_resource, author: comment_author) }

        it "does not notify the comment author" do
          expect(Decidim::EventsManager)
            .not_to receive(:publish)
            .with(
              event: "decidim.events.comments.reply_created",
              event_class: Decidim::Comments::ReplyCreatedEvent,
              resource: dummy_resource,
              affected_users: [comment_author],
              extra: {
                comment_id: comment.id
              }
            )

          subject.create
        end
      end

      context "when comment author is not replying to herself" do
        let(:top_level_comment_author) { create(:user, organization:) }
        let(:top_level_comment) { create(:comment, commentable: dummy_resource, author: top_level_comment_author) }

        it "notifies the parent comment author" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .once
            .ordered

          expect(Decidim::EventsManager)
            .to receive(:publish)
            .once
            .ordered
            .with(
              event: "decidim.events.comments.reply_created",
              event_class: Decidim::Comments::ReplyCreatedEvent,
              resource: dummy_resource,
              affected_users: a_collection_containing_exactly(top_level_comment_author),
              extra: {
                comment_id: comment.id
              }
            )

          expect(Decidim::EventsManager)
            .to receive(:publish)
            .twice
            .ordered

          subject.create
        end
      end
    end
  end

  describe "when a comment notification is created" do
    let(:event_class) { Decidim::Comments::CommentCreatedEvent }
    let(:event_name) { "decidim.events.comments.comment_created" }
    let(:extra) { { comment_id: create(:comment).id } }
    let(:user) { create(:user) }

    let(:notification) { create(:notification, user:, event_class:, event_name:, extra:) }

    it "includes the conversation link" do
      comment_id = notification.extra["comment_id"]
      comment_definition_string = "commentId=#{comment_id}#comment_#{comment_id}"
      notification_text = notification.event_class_instance.notification_title

      expect(notification_text).to include(comment_definition_string)
    end
  end
end
