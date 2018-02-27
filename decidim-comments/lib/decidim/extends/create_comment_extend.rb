# frozen_string_literal: true
# This module is use to add customs methods to the original "create_comment.rb"

module CreateCommentExtend
  def send_notification # to moderators.
    Decidim::EventsManager.publish(
      event: "decidim.events.comments.comment_created",
      event_class: Decidim::Comments::CommentCreatedEvent,
      resource: @comment.root_commentable,
      recipient_ids: (@commentable.users_to_notify_on_comment_created - [@author]).pluck(:id),
      extra: {
        comment_id: @comment.id,
        moderation_event: @comment.moderation.upstream_activated? ? true : false,
        new_content: true,
        process_slug: @comment.root_commentable.feature.participatory_space.slug
      }
    )
  end
end

Decidim::Comments::CreateComment.class_eval do
  prepend(CreateCommentExtend)
end
