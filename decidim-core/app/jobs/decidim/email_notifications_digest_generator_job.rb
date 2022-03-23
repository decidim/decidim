# frozen_string_literal: true

module Decidim
  class EmailNotificationsDigestGeneratorJob < ApplicationJob
    queue_as :events

    def perform(user_id, frequency, time: Time.now.utc)
      user = Decidim::User.find(user_id)
      return unless user

      notification_ids = user.notifications.try(frequency, time: time).pluck(:id)
      return if notification_ids.blank?

      NotificationsDigestMailer.digest_mail(user, notification_ids).deliver_later
      user.update(digest_sent_at: time)
    end
  end
end
