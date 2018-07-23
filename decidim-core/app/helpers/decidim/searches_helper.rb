# frozen_string_literal: true

module Decidim
  # A Helper to render and link to searchables.
  module SearchesHelper
    def searchable_resource_human_name(resource)
      resource.model_name.human.pluralize
    end

    def searchable_resources_as_options(all_label)
      [["", all_label]] + Decidim::Searchable.searchable_resources.values.collect do |r|
        [r.name, searchable_resource_human_name(r)]
      end.sort
    end
  end
end
