# frozen_string_literal: true

module Decidim
  # A Helper to render and link to searchables.
  module SearchesHelper
    # @param count: (optional) the number of resources so that the I18n backend can decide to translate into singluar or plural form.
    def searchable_resource_human_name(resource, count: 1)
      resource.model_name.human(count: count)
    end

    def searchable_resources_as_options(all_label)
      [["", all_label]] + Decidim::Searchable.searchable_resources.values.collect do |r|
        [r.name, searchable_resource_human_name(r, count: 2)]
      end.sort
    end
  end
end
