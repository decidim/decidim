# frozen_string_literal: true

module Decidim
  class NotificationsDigestSendingDecider
    class << self
      def must_notify?(user, time: Time.now.utc)
        return true if user.digest_sent_at.blank?

        case user.notifications_sending_frequency.to_sym
        when :none then false
        when :daily then user.digest_sent_at < time - 1.day
        when :weekly then user.digest_sent_at < time - 1.week
        else true
        end
      end
    end
  end
end
