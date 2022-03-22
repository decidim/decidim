# frozen_string_literal: true

namespace :decidim do
  namespace :mailers do
    desc "Task to send the notification digest email with the daily report"
    task notifications_digest_daily: :environment do
      notifications_digest(:daily)
    end

    desc "Task to send the notification digest email with the weekly report"
    task notifications_digest_weekly: :environment do
      notifications_digest(:weekly)
    end
  end

  def notifications_digest(frequency)
    target_users = Decidim::User.where(email_on_notification: true, notifications_sending_frequency: frequency)
    time = Time.now.utc
    target_users.find_each do |user|
      next if user_already_notified?(user, time: time)

      Decidim::EmailNotificationsDigestGeneratorJob.perform_later(user.id, frequency, time: time)
    end
  end

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
