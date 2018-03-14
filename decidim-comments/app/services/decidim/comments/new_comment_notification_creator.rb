# frozen_string_literal: true

module Decidim
  module Comments
    class NewCommentNotificationCreator
      def initialize(comment, mentioned_users)
        @comment = comment
        @mentioned_users = mentioned_users
        @already_notified_ids = []
      end

      def create
        notify_mentioned_users
        notify_parent_comment_author
        notify_author_followers
        notify_commentable_recipients
      end

      private

      attr_reader :comment, :mentioned_users, :already_notified_ids

      def notify_mentioned_users
        recipient_ids = mentioned_users.pluck(:id) - already_notified_ids
        @already_notified_ids += recipient_ids

        notify(recipient_ids, :user_mentioned)
      end

      def notify_parent_comment_author
        return if comment.depth == 0

        recipient_ids = [comment.commentable.decidim_author_id] - already_notified_ids
        @already_notified_ids += recipient_ids

        notify(recipient_ids, :reply_created)
      end

      def notify_author_followers
        recipient_ids = comment.author.followers.pluck(:id) - already_notified_ids
        @already_notified_ids += recipient_ids

        notify(recipient_ids, :comment_by_followed_user)
      end

      def notify_commentable_recipients
        recipient_ids = comment.commentable.users_to_notify_on_comment_created.pluck(:id) - already_notified_ids
        @already_notified_ids += recipient_ids

        notify(recipient_ids, :comment_created)
      end

      def notify(user_ids, event)
        return if user_ids.blank?

        event_class = "Decidim::Comments::#{event.to_s.camelcase}Event".constantize

        a={
          event: "decidim.events.comments.#{event}",
          event_class: event_class,
          resource: comment.root_commentable,
          recipient_ids: user_ids.uniq,
          extra: {
            comment_id: comment.id
          }
        }
        Decidim::EventsManager.publish(
          a
        )
      end
    end
  end
end