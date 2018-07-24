# frozen_string_literal: true

module Decidim
  module Comments
    # This class handles what events must be triggered, and to what users,
    # after a comment is created. Handles these cases:
    #
    # - A user is mentioned in the comment
    # - My comment is replied
    # - A user I'm following has created a comment/reply
    # - A new comment has been created on a resource, and I should be notified.
    #
    # A given user will only receive one of these notifications, for a given
    # comment. If need be, the code to handle this cases can be swapped easily.
    class NewCommentNotificationCreator
      # comment - the Comment from which to generate notifications.
      # mentioned_users - An ActiveRecord::Relation of the users that have been
      #   mentioned
      def initialize(comment, mentioned_users)
        @comment = comment
        @mentioned_users = mentioned_users
        @already_notified_ids = []
      end

      # Generates the notifications for the given comment.
      #
      # Returns nothing.
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

      # Notifies the author of a comment that their comment has been replied.
      # Only applies if the comment is a reply.
      def notify_parent_comment_author
        return if comment.depth.zero?

        recipient_ids = [comment.commentable.decidim_author_id] - already_notified_ids - [comment.author.id]
        @already_notified_ids += recipient_ids

        notify(recipient_ids, :reply_created)
      end

      def notify_author_followers
        recipient_ids = comment.author.followers.pluck(:id) - already_notified_ids
        @already_notified_ids += recipient_ids

        notify(recipient_ids, :comment_by_followed_user)
      end

      # Notifies the users the `comment.commentable` resource implements as necessary.
      def notify_commentable_recipients
        recipient_ids = comment.commentable.users_to_notify_on_comment_created.pluck(:id) - already_notified_ids - [comment.author.id]
        @already_notified_ids += recipient_ids

        notify(recipient_ids, :comment_created)
      end

      # Creates the notifications for the given user IDS and the given event.
      # It builds the event class from the `event` argument, and will raise an error if the
      # class cannot be found.
      #
      # user_ids - an Array of IDs
      # event - a Symbol representing the event to be notified.
      #
      # Returns nothing.
      def notify(user_ids, event)
        return if user_ids.blank?

        event_class = "Decidim::Comments::#{event.to_s.camelcase}Event".constantize

        Decidim::EventsManager.publish(
          event: "decidim.events.comments.#{event}",
          event_class: event_class,
          resource: comment.root_commentable,
          recipient_ids: user_ids.uniq,
          extra: {
            comment_id: comment.id
          }
        )
      end
    end
  end
end
