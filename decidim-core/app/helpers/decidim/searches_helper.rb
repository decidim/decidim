# frozen_string_literal: true

module Decidim
  # A Helper to render and link to resources.
  module SearchesHelper
    def radio_checked?(resource_type_radio_value)
      if @filters.nil?
        'checked="checked"' if resource_type_radio_value.blank?
      elsif @filters[:resource_type].include?(resource_type_radio_value)
        'checked="checked"'
      end
    end

    def searchable_resource_human_name(resource)
      resource.model_name.human.pluralize
    end

    def searchable_resources_as_options(all_label)
      [['', all_label]] + Decidim::Searchable.searchable_resources.collect do |r|
        [r.name,searchable_resource_human_name(r)]
      end.sort
    end
  end
end
