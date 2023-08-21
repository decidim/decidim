# frozen_string_literal: true

module Decidim
  module Sortitions
    module SortitionsHelper
      include Decidim::SanitizeHelper
      include Decidim::TranslationsHelper

      def proposal_path(proposal)
        EngineRouter.main_proxy(proposal.component).proposal_path(proposal)
      end

      def component_name
        (defined?(current_component) && translated_attribute(current_component&.name).presence) || t("decidim.components.sortitions.name")
      end

      # Generates the sortition category label
      def sortition_category_label(sortition)
        if sortition.category.present?
          return I18n.t("show.category",
                        scope: "decidim.sortitions.sortitions",
                        category: translated_attribute(sortition.category.name))
        end

        I18n.t("show.any_category", scope: "decidim.sortitions.sortitions")
      end

      # Show list of candidate proposals for a sortition. Selected sortition ids will appear with bold font.
      def sortition_proposal_candidate_ids(sortition)
        result = []
        sortition.candidate_proposals.each do |proposal_id|
          result << if sortition.selected_proposals.include? proposal_id
                      "<b>#{proposal_id}</b>"
                    else
                      proposal_id.to_s
                    end
        end

        result.join(" - ").html_safe
      end

      def filter_sections_sortitions
        sections = [{ method: :with_any_state, collection: filter_state_values, label_scope: "decidim.sortitions.sortitions.filters", id: "state" }]
        if current_participatory_space.categories.any?
          sections.append(
            method: :with_category,
            collection: filter_categories_values,
            label_scope: "decidim.sortitions.sortitions.filters", id: "category"
          )
        end
        sections.reject { |item| item[:collection].blank? }
      end

      def filter_state_values
        [
          ["all", t("all", scope: "decidim.sortitions.sortitions.filters")],
          ["active", t("active", scope: "decidim.sortitions.sortitions.filters")],
          ["cancelled", t("cancelled", scope: "decidim.sortitions.sortitions.filters")]
        ]
      end
    end
  end
end
