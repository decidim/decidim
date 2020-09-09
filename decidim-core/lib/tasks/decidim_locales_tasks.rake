# frozen_string_literal: true

namespace :decidim do
  namespace :locales do
    desc "Ensures locales in organizations are in sync with Decidim initializer"
    task sync_all: :environment do
      Decidim::Organization.all.each do |organization|
        organization.available_locales = Decidim.available_locales.filter do |lang|
          organization.available_locales.include?(lang.to_s)
        end
        organization.default_locale = organization.available_locales.first unless organization.available_locales.include? organization.default_locale
        organization.save!
      end
    end

    desc "Rebuild the search index"
    task rebuild_search: :environment do
      Decidim::SearchableResource.destroy_all
      Decidim::Searchable.searchable_resources.keys.each do |resource|
        resource.constantize.all.each(&:try_update_index_for_search_resource)
      end
    end
  end
end
