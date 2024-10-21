# frozen_string_literal: true

module Decidim
  module Accountability
    # Custom helpers, scoped to the accountability engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include Decidim::Comments::CommentsHelper
      include Decidim::MapHelper
      include Decidim::Accountability::MapHelper

      def display_percentage(number)
        return if number.blank?

        number_to_percentage(number, precision: 1, strip_insignificant_zeros: true, locale: I18n.locale)
      end

      def component_name
        (defined?(current_component) && translated_attribute(current_component&.name).presence) || t("decidim.components.accountability.name")
      end

      def filter_items_for(participatory_space:, category:)
        [
          {
            url: url_for(filter: { with_category: category.try(:id) }),
            text: t("results.filters.all", scope: "decidim.accountability"),
            icon: "apps-2-line",
            active: current_scope.blank?,
            sr_text: Decidim::Scope.model_name.human(count: 2)
          },
          *(
            if participatory_space.scope
              [{
                url: url_for(filter: { with_scope: participatory_space.scope.id, with_category: category.try(:id) }),
                text: translated_attribute(participatory_space.scope.name),
                icon: resource_type_icon_key(participatory_space.scope.class),
                active: participatory_space.scope.id.to_s == current_scope.to_s,
                sr_text: Decidim::Scope.model_name.human(count: 1)
              }]
            end
          ),
          *participatory_space.subscopes.map do |scope|
            {
              url: url_for(filter: { with_scope: scope.id, with_category: category.try(:id) }),
              text: translated_attribute(scope.name),
              icon: resource_type_icon_key(scope.class),
              active: scope.id.to_s == current_scope.to_s,
              sr_text: Decidim::Scope.model_name.human(count: 1)
            }
          end
        ]
      end

      def apply_accountability_pack_tags
        append_stylesheet_pack_tag("decidim_accountability", media: "all")
        append_javascript_pack_tag("decidim_accountability")
      end
    end
  end
end
