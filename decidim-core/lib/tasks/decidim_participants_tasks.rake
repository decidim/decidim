# frozen_string_literal: true

namespace :decidim do
  namespace :participants do
    desc "Delete inactive participants after a configurable inactivity period"
    task :delete_inactive_participants, [:days] => :environment do |_task, args|
      inactivity_period_days = args[:days]&.to_i || Decidim.delete_inactive_users_after_days
      minimum_inactivity_period = Decidim.minimum_inactivity_period

      if inactivity_period_days < minimum_inactivity_period
        raise <<~ERROR_MESSAGE
          The number of days of inactivity period is too low.
          Minimum allowed is #{minimum_inactivity_period} days.
        ERROR_MESSAGE
      end

      Decidim::Organization.find_each do |organization|
        Decidim::DeleteInactiveParticipantsJob.perform_later(organization)
      end
    end

    desc "Delete old personal data versions for participants"
    task :delete_old_versions, [:days] => :environment do |_task, args|
      raise "The days argument must be a positive integer or zero." if args.days.is_a?(String) && !args.days.match?(/\A[0-9]+\z/)

      cutoff_days = args.days&.to_i || Decidim.delete_old_personal_data_versions_days
      raise "The days argument must be a positive integer or zero." unless cutoff_days.is_a?(Integer) && cutoff_days >= 0

      Decidim::DeleteOldUserVersionsJob.perform_later(cutoff_days)
      Decidim::DeleteRevokedAuthorizationsVersionsJob.perform_later(cutoff_days)
    end
  end
end
