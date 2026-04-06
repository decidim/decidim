# frozen_string_literal: true

namespace :decidim do
  namespace :mailers do
    desc "Sends the notification digest email with the daily report"
    task notifications_digest_daily: :environment do
      time = Time.now.utc
      notification_users =
        Decidim::Notification
        .daily(time)
        .select(:decidim_user_id)
        .distinct

      target_users =
        Decidim::User.where(
          id: notification_users,
          notifications_sending_frequency: :daily
        )

      target_users.find_each do |user|
        Decidim::EmailNotificationsDigestGeneratorJob.perform_later(user.id, :daily, time:)
      end
    end

    desc "Sends the notification digest email with the weekly report"
    task notifications_digest_weekly: :environment do
      time = Time.now.utc
      notification_users =
        Decidim::Notification
        .weekly(time)
        .select(:decidim_user_id)
        .distinct

      target_users =
        Decidim::User.where(
          id: notification_users,
          notifications_sending_frequency: :weekly
        )

      target_users.find_each do |user|
        Decidim::EmailNotificationsDigestGeneratorJob.perform_later(user.id, :weekly, time:)
      end
    end
  end
end
