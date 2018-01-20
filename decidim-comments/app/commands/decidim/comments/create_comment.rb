# frozen_string_literal: true

module Decidim
  module Comments
    # A command with all the business logic to create a new comment
    class CreateComment < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form, author, commentable)
        @form = form
        @author = author
        @commentable = commentable
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          create_comment
          send_notification
        end

        broadcast(:ok, @comment)
      end

      private

      attr_reader :form

      def create_comment
        parsed = Decidim::ContentProcessor.parse(form.body)

        @comment = Comment.create!(author: @author,
                                   commentable: @commentable,
                                   root_commentable: root_commentable(@commentable),
                                   body: parsed.rewrite,
                                   alignment: form.alignment,
                                   decidim_user_group_id: form.user_group_id)

        mentioned_users = parsed.metadata[:user][:users]
        send_mention_notifications(mentioned_users) if mentioned_users.any?
      end

      def send_notification
        recipient_ids = (@commentable.users_to_notify_on_comment_created - [@author]).pluck(:id)
        recipient_ids += @author.followers.pluck(:id)

        Decidim::EventsManager.publish(
          event: "decidim.events.comments.comment_created",
          event_class: Decidim::Comments::CommentCreatedEvent,
          resource: @comment.root_commentable,
          recipient_ids: recipient_ids.uniq,
          extra: {
            comment_id: @comment.id
          }
        )
      end

      def send_mention_notifications(mentioned_users)
        recipient_ids = mentioned_users.pluck(:id)

        Decidim::EventsManager.publish(
          event: "decidim.events.comments.user_mentioned",
          event_class: Decidim::Comments::UserMentionedEvent,
          resource: @comment.root_commentable,
          recipient_ids: recipient_ids.uniq,
          extra: {
            comment_id: @comment.id
          }
        )
      end

      def root_commentable(commentable)
        return commentable.root_commentable if commentable.is_a? Decidim::Comments::Comment
        commentable
      end
    end
  end
end
