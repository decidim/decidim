# frozen_string_literal: true
# This module is use to add customs methods to the original "comment.rb"

module CommentExtend
  def send_notification # to followers. This method is called in "authorize!" method
    Decidim::EventsManager.publish(
      event: "decidim.events.comments.comment_authorized",
      event_class: Decidim::Comments::CommentAuthorizedEvent,
      resource: self.root_commentable,
      recipient_ids: (self.root_commentable.users_to_notify_on_comment_authorized - [author]).pluck(:id),
      extra: {
        comment_id: self.id
      }
    )
  end

  def create_comment_moderation
    participatory_space = self.root_commentable.feature.participatory_space
    self.create_moderation!(participatory_space: participatory_space)
  end

  def update_moderation
    unless moderation.upstream_activated?
      moderation.authorize!
    end
  end
end

Decidim::Comments::Comment.class_eval do
  prepend(CommentExtend)
  after_create :create_comment_moderation
  after_create :update_moderation
end
