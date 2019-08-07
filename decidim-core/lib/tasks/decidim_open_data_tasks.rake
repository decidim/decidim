# frozen_string_literal: true

namespace :decidim do
  namespace :open_data do
    desc "Generates the Open Data export files for each organization."
    task export: :environment do
      Decidim::Organization.find_each do |organization|
        Decidim::OpenDataJob.perform_later(organization)
      end
    end
  end
end
