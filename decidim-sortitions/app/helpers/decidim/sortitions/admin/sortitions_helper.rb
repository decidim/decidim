# frozen_string_literal: true

module Decidim
  module Sortitions
    module Admin
      module SortitionsHelper
        include Decidim::TranslationsHelper

        # Converst a list of components into a list of selectable options
        def components_options(components)
          components.map do |f|
            [translated_attribute(f.name), f.id]
          end
        end

        def sortition_category(sortition)
          return translated_attribute sortition.category&.name if sortition.category

          I18n.t("sortitions.form.all_categories", scope: "decidim.sortitions.admin")
        end
      end
    end
  end
end
