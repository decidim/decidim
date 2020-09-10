# frozen_string_literal: true

namespace :decidim do
  namespace :locales do
    desc "Ensures locales in organizations are in sync with Decidim initializer"
    task sync_all: :environment do
      allowed_locales = Decidim.available_locales.map(&:to_s)
      Decidim::Organization.find_each do |organization|
        print "#{organization.name} uses #{organization.available_locales} with [#{organization.default_locale}] as default"

        orphan = (organization.available_locales - allowed_locales)
        organization.available_locales = organization.available_locales - orphan
        default = organization.default_locale
        organization.default_locale = organization.available_locales.first unless organization.available_locales.include? default
        if default != organization.default_locale || orphan.present?
          organization.save!
          puts " [FIXED]"
        else
          puts " [OK]"
        end
      end
    end

    desc "Rebuild the search index"
    task rebuild_search: :environment do
      Decidim::SearchableResource.destroy_all
      total = Decidim::Searchable.searchable_resources.count
      Decidim::Searchable.searchable_resources.values.each.with_index(1) do |klass, index|
        print "Indexing #{index}/#{total} #{klass}"
        klass.find_each(&:try_update_index_for_search_resource)
        puts " [DONE]"
      end
    end
  end
end
