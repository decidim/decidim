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
  end
end
