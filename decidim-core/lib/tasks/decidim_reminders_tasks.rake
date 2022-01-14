# frozen_string_literal: true

namespace :decidim do
  namespace :reminders do
    task :all, [] => :environment do
      Decidim.reminders_registry.all.each do |reminder_manifest|
        call_reminder_job(reminder_manifest)
      end
    end
  end

  def call_reminder_job(reminder_manifest)
    Decidim::ReminderGeneratorJob.perform_later(
      reminder_manifest.generator_class_name
    )
  end
end
