# frozen_string_literal: true

module CreateCommentExtend
  # send notification to moderators
  def send_notification
    Decidim::EventsManager.publish(
      event:         "decidim.events.comments.comment_created",
      event_class:   Decidim::Comments::CommentCreatedEvent,
      resource:      @comment.root_commentable,
      recipient_ids: (@commentable.users_to_notify_on_comment_created - [@author]).pluck(:id),
      extra:         {
        comment_id:   @comment.id,
        new_content:  true,
        process_slug: @comment.root_commentable.feature.participatory_space.slug
      }
    )
  end
end

Decidim::Comments::CreateComment.class_eval do
  prepend(CreateCommentExtend)
end
