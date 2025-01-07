# frozen_string_literal: true

module Decidim
  module Sortitions
    module Admin
      module SortitionsHelper
        include Decidim::TranslationsHelper
        include Decidim::PaginateHelper
        include Decidim::SanitizeHelper

        # Converts a list of components into a list of selectable options
        def components_options(components)
          components.map do |f|
            [translated_attribute(f.name), f.id]
          end
        end

        def sortition_taxonomies(sortition)
          taxonomies = sortition.taxonomies.map { |taxonomy| decidim_sanitize_translated(taxonomy.name) }.join(", ")
          return taxonomies if taxonomies.present?

          I18n.t("sortitions.form.all_taxonomies", scope: "decidim.sortitions.admin")
        end
      end
    end
  end
end
