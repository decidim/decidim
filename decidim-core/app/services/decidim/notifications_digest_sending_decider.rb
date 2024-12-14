# frozen_string_literal: true

module Decidim
  class NotificationsDigestSendingDecider
    class << self
      def must_notify?(user, time = Time.now.utc)

        # TODO: seems that .blank? applies to first time users
        # as well as existing users
        # find another way of determining whether a user is new
        # and then sending the digest based on that.
        # Alternatively changing/removing the spec

        # Note that we are checking whether the notifications were sent at any
        # time during the assumed sending day moment to prevent potential issues
        # during the sending if the digest_sent_at is set to some other moment
        # than the exact beginning of that day.
        case user.notifications_sending_frequency.to_sym
        when :none then false
        when :daily
          frequency = user.notifications_sending_frequency.to_sym
          notification_ids = user.notifications.try(frequency, time).pluck(:id)
          if notification_ids.present? && user.digest_sent_at.blank?
            return true
          elsif user.digest_sent_at.present?
            return true if user.digest_sent_at <= (time - 1.day).end_of_day
            return true if user.digest_sent_at <= (time - 2.days).end_of_day
            return false if user.digest_sent_at = (time - 1.hour)
          else
            return false
          end
        when :weekly then user.digest_sent_at <= (time - 1.day - 1.week).end_of_day
        else true
        end
      end
    end
  end
end
