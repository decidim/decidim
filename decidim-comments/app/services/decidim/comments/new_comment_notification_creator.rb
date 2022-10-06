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
    # comment. The comment author will never be notified about their own comment.
    # If need be, the code to handle this cases can be swapped easily.
    class NewCommentNotificationCreator
      # comment - the Comment from which to generate notifications.
      # mentioned_users - An ActiveRecord::Relation of the users that have been
      #   mentioned
      # mentioned_groups - And ActiveRecord::Relation of the user_groups that have
      #   been mentioned
      def initialize(comment, mentioned_users, mentioned_groups = nil)
        @comment = comment
        @mentioned_users = mentioned_users
        @mentioned_groups = mentioned_groups
        @already_notified_users = [comment.author]
      end

      # Generates the notifications for the given comment.
      #
      # Returns nothing.
      def create
        notify_mentioned_users
        notify_mentioned_groups
        notify_parent_comment_author
        notify_author_followers
        notify_user_group_followers
        notify_commentable_recipients
      end

      private

      attr_reader :comment, :mentioned_users, :mentioned_groups, :already_notified_users

      def notify_mentioned_users
        affected_users = mentioned_users - already_notified_users
        @already_notified_users += affected_users

        notify(:user_mentioned, affected_users:)
      end

      def notify_mentioned_groups
        return unless mentioned_groups

        mentioned_groups.each do |group|
          affected_users = group.accepted_users - already_notified_users
          @already_notified_users += affected_users

          notify(:user_group_mentioned, affected_users:, extra: { group_id: group.id })
        end
      end

      # Notifies the author of a comment that their comment has been replied.
      # Only applies if the comment is a reply.
      def notify_parent_comment_author
        return if comment.depth.zero?

        affected_users = [comment.commentable.author] - already_notified_users
        @already_notified_users += affected_users

        notify(:reply_created, affected_users:)
      end

      def notify_author_followers
        followers = comment.author.followers - already_notified_users
        @already_notified_users += followers

        notify(:comment_by_followed_user, followers:)
      end

      def notify_user_group_followers
        return if comment.user_group.blank?

        followers = comment.user_group.followers - already_notified_users
        @already_notified_users += followers

        notify(:comment_by_followed_user_group, followers:)
      end

      # Notifies the users the `comment.commentable` resource implements as necessary.
      def notify_commentable_recipients
        followers = comment.commentable.users_to_notify_on_comment_created - already_notified_users
        @already_notified_users += followers

        notify(:comment_created, followers:)
      end

      # Creates the notifications for the given user IDS and the given event.
      # It builds the event class from the `event` argument, and will raise an error if the
      # class cannot be found.
      #
      # users - a Hash with `followers` and `affected_users` keys, both containing
      #   a collection of users.
      # event - a Symbol representing the event to be notified.
      #
      # Returns nothing.
      def notify(event, users)
        return if users.values.flatten.blank?

        event_class = "Decidim::Comments::#{event.to_s.camelcase}Event".constantize
        data = {
          event: "decidim.events.comments.#{event}",
          event_class:,
          resource: comment.root_commentable,
          extra: {
            comment_id: comment.id
          }
        }.deep_merge(users)

        Decidim::EventsManager.publish(**data)
      end
    end
  end
end
