# frozen_string_literal: true

namespace :decidim do
  namespace :batch_email_notifications do
    desc "Send email notifications in batch"
    task send: :environment do
      Decidim::BatchEmailNotificationsGeneratorJob.perform_later
    end
  end
end
