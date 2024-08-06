# frozen_string_literal: true

module Decidim
  # A Helper to render scopes, including a global scope, for forms.
  module TaxonomiesHelper
    include DecidimFormHelper
    include TranslatableAttributes

    def filter_taxonomy_items_select_field(form, name, filter, options: {})
      options = options.merge(include_blank: I18n.t("decidim.taxonomies.prompt", name: translated_attribute(filter.name))) unless options.has_key?(:include_blank)
      options = options.merge(label: translated_attribute(filter.name)) unless options.has_key?(:label)
      form.select(
        name,
        taxonomy_items_options(filter.filter_items.pluck(:taxonomy_item_id)),
        options,
        { name: "#{form.object_name}[#{name}][]" }
      )
    end

    def taxonomy_items_options(taxonomies)
      taxonomy_items = current_organization.taxonomies.where(id: taxonomies)
      taxonomy_items.map { |item| [translated_attribute(item.name), item.id] }
    end
  end
end
