# frozen_string_literal: true

module Decidim
  # A Helper to render and link to resources.
  module SearchesHelper
    def radio_checked?(resource_type_radio_value)
      if @filters.nil?
        'checked="checked"' if resource_type_radio_value.blank?
      else
        'checked="checked"' if @filters[:resource_type].include?(resource_type_radio_value)
      end
    end

    def searchable_resources_class_names
      searchable_resources ||= []
      Decidim::Searchable.searchable_resources.each do |resource|
        searchable_resources << resource.constantize.model_name.singular
      end
      searchable_resources
      Decidim::Searchable.searchable_resources
    end

    def searchable_resource_human_name(searchable_resources_model_name)
      searchable_resources_model_name.constantize.model_name.human
    end
  end
end
