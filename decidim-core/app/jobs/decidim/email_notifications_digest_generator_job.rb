# frozen_string_literal: true

module Decidim
  class EmailNotificationsDigestGeneratorJob < ApplicationJob
    queue_as :mailers

    def perform(user_id, frequency, time: Time.now.utc, force: false)
      user = Decidim::User.find_by(id: user_id)
      return if user.blank?

      should_notify = force || !user_already_notified?(user, time: time)
      return unless should_notify

      notification_ids = user.notifications.try(frequency, time: time).pluck(:id)
      return if notification_ids.blank?

      NotificationsDigestMailer.digest_mail(user, notification_ids).deliver_later
      user.update(digest_sent_at: time)
    end

    private

    def user_already_notified?(user, time: Time.now.utc)
      return false if user.digest_sent_at.blank?

      case user.notifications_sending_frequency
      when :none then true # true to avoid notifying the user then the frequency is none
      when :daily then user.digest_sent_at > time - 1.day
      when :weekly then user.digest_sent_at > time - 1.week
      else false
      end
    end
  end
end
