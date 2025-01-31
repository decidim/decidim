# frozen_string_literal: true

module Decidim
  module Initiatives
    # Helper functions for initiatives views
    module InitiativesHelper
      # Items to display in the navigation of an initiative
      def initiative_nav_items(participatory_space)
        components = participatory_space.components.published.or(Decidim::Component.where(id: try(:current_component)))

        components.map do |component|
          {
            name: decidim_escape_translated(component.name),
            url: main_component_path(component),
            active: is_active_link?(main_component_path(component), :inclusive)
          }
        end
      end

      private

      # i18n-tasks-use t('decidim.initiatives.initiatives.filters.state')
      # i18n-tasks-use t('decidim.initiatives.initiatives.filters.scope')
      # i18n-tasks-use t('decidim.initiatives.initiatives.filters.type')
      # i18n-tasks-use t('decidim.initiatives.initiatives.filters.area')
      # i18n-tasks-use t('decidim.initiatives.initiatives.filters.author')
      def filter_sections
        sections = [
          { method: :with_any_state, collection: filter_states_values, label: t("decidim.initiatives.initiatives.filters.state"), id: "state" },
          { method: :with_any_scope, collection: filter_global_scopes_values, label: t("decidim.initiatives.initiatives.filters.scope"), id: "scope" }
        ]
        unless single_initiative_type?
          sections.append(method: :with_any_type, collection: filter_types_values, label: t("decidim.initiatives.initiatives.filters.type"),
                          id: "type")
        end
        sections.append(method: :with_any_area, collection: filter_areas_values, label: t("decidim.initiatives.initiatives.filters.area"), id: "area")
        sections.reject { |item| item[:collection].blank? }
      end

      def filter_author_values
        [
          ["any", t("any", scope: "decidim.initiatives.initiatives.filters")],
          ["myself", t("myself", scope: "decidim.initiatives.initiatives.filters")]
        ]
      end
    end
  end
end
