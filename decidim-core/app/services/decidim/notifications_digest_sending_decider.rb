# frozen_string_literal: true

module Decidim
  class NotificationsDigestSendingDecider
    class << self
      def must_notify?(user, time: Time.now.utc)
        return true if user.digest_sent_at.blank?

        # Note that we are checking whether the notifications were sent at any
        # time during the assumed sending day moment to prevent potential issues
        # during the sending if the digest_sent_at is set to some other moment
        # than the exact beginning of that day.
        case user.notifications_sending_frequency.to_sym
        when :none then false
        when :daily then user.digest_sent_at <= (time - 1.day).end_of_day
        when :weekly then user.digest_sent_at <= (time - 1.day - 1.week).end_of_day
        else true
        end
      end
    end
  end
end
