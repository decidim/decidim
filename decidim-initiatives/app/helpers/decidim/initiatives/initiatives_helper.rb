# frozen_string_literal: true

module Decidim
  module Initiatives
    # Helper functions for initiatives views
    module InitiativesHelper
      def initiatives_filter_form_for(filter)
        content_tag :div, class: "filters" do
          form_for filter,
                   namespace: filter_form_namespace,
                   builder: Decidim::Initiatives::InitiativesFilterFormBuilder,
                   url: url_for,
                   as: :filter,
                   method: :get,
                   remote: true,
                   html: { id: nil } do |form|
            yield form
          end
        end
      end

      # Items to display in the navigation of an initiative
      def initiative_nav_items(participatory_space)
        components = participatory_space.components.published.or(Decidim::Component.where(id: try(:current_component)))

        [
          {
            name: t("initiative_menu_item", scope: "layouts.decidim.initiative_header"),
            url: decidim_initiatives.initiative_path(participatory_space),
            active: is_active_link?(decidim_initiatives.initiative_path(participatory_space), :exclusive) ||
              is_active_link?(decidim_initiatives.initiative_versions_path(participatory_space), :inclusive)
          }
        ] + components.map do |component|
          {
            name: translated_attribute(component.name),
            url: main_component_path(component),
            active: is_active_link?(main_component_path(component), :inclusive)
          }
        end
      end

      private

      # Creates a unique namespace for a filter form to prevent dupliacte IDs in
      # the DOM when multiple filter forms are rendered with the same fields (e.g.
      # for desktop and mobile).
      def filter_form_namespace
        "filters_#{SecureRandom.uuid}"
      end
    end
  end
end
