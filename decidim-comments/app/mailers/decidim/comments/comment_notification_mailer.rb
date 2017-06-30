# frozen_string_literal: true

module Decidim
  module Comments
    # A custom mailer for sending notifications to users when
    # a comment is created.
    class CommentNotificationMailer < Decidim::ApplicationMailer
      helper Decidim::ResourceHelper

      helper_method :commentable_title

      def comment_created(user, comment, commentable)
        with_user(user) do
          @user = user
          @comment = comment
          @commentable = commentable
          @locator = Decidim::ResourceLocatorPresenter.new(@commentable)
          @organization = commentable.organization
          subject = I18n.t("comment_created.subject", scope: "decidim.comments.mailer.comment_notification")
          mail(to: user.email, subject: subject)
        end
      end

      def reply_created(user, reply, comment, commentable)
        with_user(user) do
          @user = user
          @reply = reply
          @comment = comment
          @commentable = commentable
          @locator = Decidim::ResourceLocatorPresenter.new(@commentable)
          @organization = commentable.organization
          subject = I18n.t("reply_created.subject", scope: "decidim.comments.mailer.comment_notification")
          mail(to: user.email, subject: subject)
        end
      end

      private

      def commentable_title
        @commentable.title.is_a?(Hash) ? @commentable.title[I18n.locale.to_s] : @commentable.title
      end
    end
  end
end
