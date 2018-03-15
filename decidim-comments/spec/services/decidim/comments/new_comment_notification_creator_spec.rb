# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::NewCommentNotificationCreator do
  subject { described_class.new(comment, mentioned_users) }

  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization: organization) }
  let(:component) { create(:component, participatory_space: participatory_process) }
  let(:comment_author) { create(:user, organization: organization) }
  let(:dummy_resource) { create :dummy_resource, component: component, author: commentable_author }
  let(:commentable) { dummy_resource }
  let(:comment) { create :comment, author: comment_author, commentable: commentable, root_commentable: dummy_resource }

  let(:mentioned_user) { create(:user, organization: organization) }
  let(:mentioned_user_following_comment_author) { create(:user, organization: organization) }
  let(:user_following_comment_author) { create(:user, organization: organization) }
  let(:commentable_author) { create(:user, organization: organization) }
  let(:commentable_follower) { create(:user, organization: organization) }

  let(:mentioned_users) do
    Decidim::User.where(
      id: [
        mentioned_user.id,
        mentioned_user_following_comment_author.id
      ]
    )
  end
  let(:commentable_recipients) do
    Decidim::User.where(
      id: [
        commentable_follower.id,
        commentable_author.id
      ]
    )
  end

  before do
    create :follow, user: user_following_comment_author, followable: comment_author
    create :follow, user: mentioned_user_following_comment_author, followable: comment_author
    create :follow, user: commentable_follower, followable: commentable
    create :follow, user: commentable_author, followable: commentable

    allow(commentable)
      .to receive(:users_to_notify_on_comment_created)
      .and_return(commentable_recipients)
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
        recipient_ids: a_collection_containing_exactly(*mentioned_users.pluck(:id)),
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
        recipient_ids: a_collection_containing_exactly(user_following_comment_author.id),
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
        recipient_ids: a_collection_containing_exactly(*commentable_recipients.pluck(:id)),
        extra: {
          comment_id: comment.id
        }
      )

    subject.create
  end

  context "when replying another comment" do
    let(:top_level_comment) { create :comment, commentable: dummy_resource, author: top_level_comment_author }
    let(:top_level_comment_author) { create(:user, organization: organization) }
    let(:commentable) { top_level_comment }

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
          recipient_ids: a_collection_containing_exactly(top_level_comment_author.id),
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
