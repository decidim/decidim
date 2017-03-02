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
        send_notification_to_author if has_author? && !same_author?

        broadcast(:ok, @comment)
      end

      private

      attr_reader :form

      def create_comment
        @comment = Comment.create!(author: @author,
                                   commentable: @commentable,
                                   body: form.body,
                                   alignment: form.alignment,
                                   decidim_user_group_id: form.user_group_id)
      end

      def send_notification_to_author
        if @comment.depth > 0 && @commentable.author.replies_notifications?
          CommentNotificationMailer.reply_created(@author, @comment, @commentable, @comment.root_commentable).deliver_later
        elsif @comment.depth == 0 && @commentable.author.comments_notifications?
          CommentNotificationMailer.comment_created(@author, @comment, @commentable).deliver_later
        end
      end

      def has_author?
        @commentable.respond_to?(:author) && @commentable.author.present?
      end

      def same_author?
        @author == @commentable.author
      end
    end
  end
end
