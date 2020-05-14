# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::NewCommentNotificationCreator do
  subject { described_class.new(comment, mentioned_users) }

  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization: organization) }
  let(:component) { create(:component, participatory_space: participatory_process) }
  let(:dummy_resource) { create :dummy_resource, component: component, author: commentable_author }
  let(:commentable) { dummy_resource }
  let(:mentioned_user) { create(:user, organization: organization) }
  let(:another_mentioned_user) { create(:user, organization: organization) }
  let(:user_following_comment_author) { create(:user, organization: organization) }
  let(:commentable_author) { create(:user, organization: organization) }
  let(:commentable_recipient) { create(:user, organization: organization) }

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
    let(:comment_author) { create(:user, organization: organization) }
    let(:comment) { create :comment, author: comment_author, commentable: commentable, root_commentable: dummy_resource }

    before do
      create :follow, user: user_following_comment_author, followable: comment_author
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

    context "when the author mentions a group" do
      subject { described_class.new(comment, mentioned_users, mentioned_groups) }

      let(:group) { create :user_group, organization: organization, users: [another_mentioned_user] }
      let(:mentioned_users) { [] }
      let(:mentioned_groups) do
        Decidim::UserGroup.where(
          id: [
            group.id
          ]
        )
      end
      let(:affected_group_users) do
        Decidim::User.where(
          id: [
            mentioned_user.id,
            another_mentioned_user.id
          ]
        )
      end
      let(:role) { :member }
      let!(:pending_membership) { create(:user_group_membership, user: mentioned_user, user_group: group, role: role) }

      it "notifies the group members" do
        expect(Decidim::EventsManager)
          .to receive(:publish)
          .once
          .ordered
          .with(
            event: "decidim.events.comments.user_group_mentioned",
            event_class: Decidim::Comments::UserGroupMentionedEvent,
            resource: dummy_resource,
            affected_users: a_collection_containing_exactly(*affected_group_users),
            extra: {
              comment_id: comment.id,
              group: group
            }
          )
        expect(Decidim::EventsManager)
          .to receive(:publish)
          .twice
          .ordered

        subject.create
      end

      context "and also mentions a member of the group" do
        let(:mentioned_users) do
          Decidim::User.where(
            id: [
              mentioned_user.id
            ]
          )
        end
        let(:affected_group_users) do
          Decidim::User.where(
            id: [
              another_mentioned_user.id
            ]
          )
        end

        it "the user mentioned does not get notified as a group member" do
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
            .once
            .ordered
            .with(
              event: "decidim.events.comments.user_group_mentioned",
              event_class: Decidim::Comments::UserGroupMentionedEvent,
              resource: dummy_resource,
              affected_users: a_collection_containing_exactly(*affected_group_users),
              extra: {
                comment_id: comment.id,
                group: group
              }
            )
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .twice
            .ordered

          subject.create
        end
      end

      context "and a member of the group is not accepted" do
        let(:role) { :invited }
        let(:affected_group_users) do
          Decidim::User.where(
            id: [
              another_mentioned_user.id
            ]
          )
        end

        it "the not accepted member is not notified" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .once
            .ordered
            .with(
              event: "decidim.events.comments.user_group_mentioned",
              event_class: Decidim::Comments::UserGroupMentionedEvent,
              resource: dummy_resource,
              affected_users: a_collection_containing_exactly(*affected_group_users),
              extra: {
                comment_id: comment.id,
                group: group
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

      it "does not notify comment author even if it's following the commentable" do
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
        let(:top_level_comment) { create :comment, commentable: dummy_resource, author: comment_author }

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
        let(:top_level_comment_author) { create(:user, organization: organization) }
        let(:top_level_comment) { create :comment, commentable: dummy_resource, author: top_level_comment_author }

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

  describe "when the author is a user_group with followers" do
    let(:user_following_user_group) { create(:user, organization: organization) }
    let(:user_group_author) { create(:user_group, :verified, organization: organization, users: [user_following_user_group, commentable_author]) }
    let(:user_group_comment) { create :comment, author: commentable_author, commentable: commentable, root_commentable: dummy_resource, decidim_user_group_id: user_group_author.id }

    before do
      create :follow, user: user_following_user_group, followable: user_group_author
    end

    it "notifies the followers of the user_group" do
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .once
        .ordered
        .with(
          event: "decidim.events.comments.comment_by_followed_user_group",
          event_class: Decidim::Comments::CommentByFollowedUserGroupEvent,
          resource: dummy_resource,
          followers: a_collection_containing_exactly(user_following_user_group),
          extra: { comment_id: user_group_comment.id }
        )
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .once
        .ordered

      described_class.new(user_group_comment, []).create
    end
  end
end
