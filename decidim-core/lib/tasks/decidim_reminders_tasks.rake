# frozen_string_literal: true

namespace :decidim do
  namespace :reminders do
    task :all, :environment do
      Decidim::Organization.find_each do |organization|
        Decidim.reminders_registry.all.each do |reminder_manifest|
          call_reminder_job(reminder_manifest, organization)
        end
      end
    end
  end

  def call_reminder_job(reminder_manifest, organization)
    Decidim::ReminderGeneratorJob.perform_later(
      reminder_manifest,
      organization
    )
  end
end
