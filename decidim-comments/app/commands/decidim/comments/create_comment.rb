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

        create_comment
        send_notification if @commentable.notifiable?(author: @author)

        broadcast(:ok, @comment)
      end

      private

      attr_reader :form

      def create_comment
        @comment = Comment.create!(author: @author,
                                   commentable: @commentable,
                                   root_commentable: root_commentable(@commentable),
                                   body: form.body,
                                   alignment: form.alignment,
                                   decidim_user_group_id: form.user_group_id)
      end

      def send_notification
        if @comment.depth.positive?
          @commentable.users_to_notify.each do |user|
            CommentNotificationMailer.reply_created(user, @comment, @commentable, @comment.root_commentable).deliver_later
          end
        elsif @comment.depth.zero?
          @commentable.users_to_notify.each do |user|
            CommentNotificationMailer.comment_created(user, @comment, @commentable).deliver_later
          end
        end
      end

      def root_commentable(commentable)
        return commentable.root_commentable if commentable.is_a? Decidim::Comments::Comment
        commentable
      end
    end
  end
end
