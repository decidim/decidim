# frozen_string_literal: true

module Decidim
  class NotificationsDigestMailerPreview < ActionMailer::Preview
    def digest_mail
      NotificationsDigestMailer.digest_mail(user, notification_ids)
    end

    private

    def user
      User.last
    end

    def notification_ids
      Decidim::Notification.last(10).pluck(:id)
    end
  end
end
