# frozen_string_literal: true
module Decidim
  module Comments
    # A custom mailer for sending notifications to users when
    # a comment is created.
    class CommentNotificationMailer < Decidim::ApplicationMailer
      def comment_created(user, comment, commentable)
        with_user(user) do
          @comment = comment
          @commentable = commentable
          subject = I18n.t("comment_created.subject", scope: "decidim.comments.mailer.comment_notification")
          mail(to: commentable.author.email, subject: subject)
        end
      end
    end
  end
end
