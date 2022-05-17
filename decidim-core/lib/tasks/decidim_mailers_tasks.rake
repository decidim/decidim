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
    target_users = Decidim::User.where(notifications_sending_frequency: frequency)
    time = Time.now.utc
    target_users.find_each do |user|
      Decidim::EmailNotificationsDigestGeneratorJob.perform_later(user.id, frequency, time: time)
    end
  end
end
