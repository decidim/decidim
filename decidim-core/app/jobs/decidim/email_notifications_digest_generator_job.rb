# frozen_string_literal: true

module Decidim
  class EmailNotificationsDigestGeneratorJob < ApplicationJob
    queue_as :events

    def perform(user_id, frequency, time: Time.now.utc)
      user = Decidim::User.find(user_id)
      return unless user

      notifications = user.notifications.try(frequency, time: time).presence
      return if notifications.blank?

      NotificationsDigestMailer.digest_mail(user, notifications).deliver_later
      user.update(digest_sent_at: time)
    end
  end
end
