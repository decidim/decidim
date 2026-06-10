# frozen_string_literal: true

namespace :decidim do
  namespace :mailers do
    desc "Sends the notification digest email with the daily report"
    task notifications_digest_daily: :environment do
      time = Time.now.utc
      target_users = Decidim::User.where(notifications_sending_frequency: :daily)

      target_users.find_in_batches do |batch|
        notification_users =
          Decidim::Notification
          .daily(time)
          .where(decidim_user_id: batch.pluck(:id))
          .select(:decidim_user_id)
          .distinct
          .pluck(:decidim_user_id)

        notification_users.each do |user_id|
          Decidim::EmailNotificationsDigestGeneratorJob.perform_later(user_id, :daily, time:)
        end
      end
    end

    desc "Sends the notification digest email with the weekly report"
    task notifications_digest_weekly: :environment do
      time = Time.now.utc
      target_users = Decidim::User.where(notifications_sending_frequency: :weekly)

      target_users.find_in_batches do |batch|
        notification_users =
          Decidim::Notification
          .weekly(time)
          .where(decidim_user_id: batch.pluck(:id))
          .select(:decidim_user_id)
          .distinct
          .pluck(:decidim_user_id)

        notification_users.each do |user_id|
          Decidim::EmailNotificationsDigestGeneratorJob.perform_later(user_id, :weekly, time:)
        end
      end
    end
  end
end
