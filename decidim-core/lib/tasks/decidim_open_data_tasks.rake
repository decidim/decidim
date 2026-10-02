# frozen_string_literal: true

namespace :decidim do
  namespace :open_data do
    desc "Generates the Open Data export files for each organization."
    task export: :environment do
      resource_names = (
        Decidim.open_data_manifests.select(&:include_in_open_data).map(&:name) +
        Decidim.component_manifests.flat_map(&:export_manifests).select(&:include_in_open_data?).map(&:name) +
        Decidim.participatory_space_manifests.flat_map(&:export_manifests).select(&:include_in_open_data?).map(&:name)
      ).uniq

      Decidim::Organization.find_each do |organization|
        Decidim::OpenDataJob.perform_later(organization)
        resource_names.each { |resource| Decidim::OpenDataJob.perform_later(organization, resource) }
      end
    end
  end
end
