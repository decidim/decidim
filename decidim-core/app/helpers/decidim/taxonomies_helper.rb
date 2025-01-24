# frozen_string_literal: true

module Decidim
  # A Helper to render taxonomies for forms.
  module TaxonomiesHelper
    include DecidimFormHelper
    include TranslatableAttributes

    def filter_taxonomy_items_select_field(form, name, filter, options = {})
      label = decidim_sanitize_translated(options.delete(:internal) ? filter.internal_name : filter.name)
      options = options.merge(include_blank: I18n.t("decidim.taxonomies.prompt")) unless options.has_key?(:include_blank)
      options = options.merge(label:) unless options.has_key?(:label)
      form.select(
        name,
        taxonomy_items_options_for_filter(filter),
        options,
        { name: "#{form.object_name}[#{name}][]", id: "#{name}-#{filter.id}" }
      )
    end

    def taxonomy_items_options_for_filter(filter)
      @taxonomy_items_options_for_filter ||= {}
      @taxonomy_items_options_for_filter[filter.id] ||= begin
        min_parent_count = filter.taxonomies.values.min_by { |item| item[:taxonomy].parent_ids.count }
        first_parent_level = (min_parent_count && min_parent_count[:taxonomy].parent_ids.count) || 1
        taxonomy_items_options_for_taxonomies_tree(filter.taxonomies, first_parent_level)
      end
    end

    def taxonomy_items_options_for_taxonomies_tree(taxonomies_tree, first_parent_level = 1)
      options = []
      taxonomies_tree.each do |id, item|
        name = " #{"&nbsp;" * 4 * (item[:taxonomy].parent_ids.count - first_parent_level)} #{decidim_sanitize_translated(item[:taxonomy].name)}".html_safe
        options.append([name, id])
        options.concat(taxonomy_items_options_for_taxonomies_tree(item[:children], first_parent_level)) if item[:children].any?
      end
      options
    end
  end
end
